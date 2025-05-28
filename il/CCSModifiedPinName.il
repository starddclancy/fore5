/*************************************************************************
* DISCLAIMER: The email attachment code is provided for Cadence customers*
* to use at their own risk. The code may require modification to*
* satisfy the requirements of any user. The code and any modifications*
* to the code may not be compatible with current or future versions of*
* Cadence products. THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES,*
* INCLUDING WITHOUT LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED*
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.*
*************************************************************************/
procedure(CCSModifiedPinName(libName fileName  @optional (viewlist list("schematic" "symbol")) (toolName_list list("auCdl" "auLvs" "hspiceD" "spectre")))
    let( (inPort nextline source target sourceitem source_array target_array)
        source='()
        target='()
        inPort = infile(fileName)
        when(inPort
            while(z=gets(nextline inPort)
                source=cons(nth(0 parseString(z)) source)
                target=cons(nth(1 parseString(z)) target)
            ) ;while
            source_array=listToVector(source)
            target_array=listToVector(target)
            libId = ddGetObj(libName)
            foreach(cellId libId~>cells
                foreach(cell_viewId cellId~>views
                    if(rexMatchList(cell_viewId~>name viewlist) then
                        cv=dbOpenCellViewByType(libName cellId~>name cell_viewId~>name "" "a")
                        number_item=0 
                        foreach(sourceitem source
                            if(source_array[number_item]!=nil && target_array[number_item]!=nil then
                                CCSChangePin(libName cv source_array[number_item] target_array[number_item])
                            );if
                            number_item=number_item+1
                        );foreach
                        dbCheck(cv)                 
                        dbSave(cv)
                        dbClose(cv)
                    );if
                );foreach
                checkandSave(libName cellId toolName_list)
                ddReleaseObj(cellId)
            );foreach
            ddReleaseObj(libId)
            close(inPort)
        );when
    );let
);procedure


procedure(CCSChangePin(libName cv oldName newName)
    let((labelString oldTerm newNet)
        oldTerm=car(setof(x cv~>terminals x~>name==oldName))
        if(oldTerm then
            oldTerm~>name=newName
            foreach(pin oldTerm~>pins
                foreach(child pin~>fig~>children
                    if(child~>theLabel==oldName then
                        println(child~>theLabel)
                        child~>theLabel=newName
                    );if
                ) ;foreach child
            ) ;foreach pin

            foreach(net cv~>nets
                if(net~>name==oldName then
                    newNet = dbMakeNet(cv newName)
                    dbMergeNet(newNet net)
                    foreach( fig newNet~>figs
                        when( fig~>objType == "label"
                            fig~>theLabel = newName
                            println(fig~>theLabel)
                        ) ; end when
                    ) ;end foreach
                );if
            ) ; end foreach net label

            foreach(y cv~>shapes
                labelString = y~>theLabel
                when(stringp(labelString)
                    when(labelString == buildString(list(concat("cdsTerm(\"" oldName "\")" )))
                        y~>theLabel = buildString(list(concat("cdsTerm(\"" newName "\")" )))
                    );end 
                    when(labelString == oldName
                        y~>theLabel = newName
                    );when
                );end When stringp
            );end Foreach cv~>shapes
            
            printf("\n Replaced pin %s with %s \n" oldName newName)

        else
            printf("\n Pin %s not found \n" oldName)
        );if

    );let
);procedure CCSChangePin


procedure(checkandSave(libName cellId toolName_list)
    let((cv cell_viewId)
        foreach(cell_viewId cellId~>views
            if(rexMatchList(cell_viewId~>name '("schematic" "symbol")) then
                println(cell_viewId~>name)
                cv=dbOpenCellViewByType(libName cellId~>name cell_viewId~>name "" "a")
                if(cell_viewId~>name=="schematic" then
                    CCSsyncPortTermOrderSchChkSave(cv toolName_list)
                );if
                schVIC(cv)
                dbSave(cv)
                dbClose(cv)
            );if
        );foreach
    );let
);procedure checkandSave


procedure(CCSsyncPortTermOrderSchChkSave(cv toolName_list)
    let( (pinlist_sch )
        pinlist_sch = schGetPinOrder(cv)
        foreach(toolName toolName_list
            when(almGetTerminalList(cv~>libName cv~>cellName ?tool toolName)!=pinlist_sch   ;; update simulator name in condition
                almSetTerminalList(cv~>libName cv~>cellName pinlist_sch ?tool toolName)
                printf("Setting %s termOrder to %L for cell %s \n" toolName pinlist_sch cv~>cellName)
            );when
            ddsRefresh(?cdf t) 
        );
    ) ;let
) ;procedure CCSsyncPortTermOrderSchChkSave


