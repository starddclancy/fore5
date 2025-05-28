/********************************************************************
* DISCLAIMER: The following code is provided for Cadence customers *
* to use at their own risk. The code may require modification to   *
* satisfy the requirements of any user. The code and any       *
* modifications to the code may not be compatible with current or  *
* future versions of Cadence products.                   *
* THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, INCLUDING   *
* WITHOUT LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED WARRANTIES  *
* OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.           *
********************************************************************/

/* USAGE:
Load the SKILL code in CIW:
load "CCSchangeLabel.il"

To change the pin, net and label names of the schematic cells in library named myLib call in CIW:
CCSchangeLabel("myLib" "schematic")

The output will be:
Opened view "schematic" from cell "sigType" of library "myLib" for edit.
Job Done...
t

To run the same for symbol views of entire library:
CCSchangeLabel("myLib" "symbol")

NOTE: The SKILL code is for converting all pin, net and labels to upper case.
If the intent is to change it to lower case, change all occurrences of command
upperCase to lowerCase in SKILL code. Or comment out the entry containing upperCase
and uncomment entry containing lowerCase in the code. Semicolon has been used for
commenting out particular lines in this code.

The code also provides a function CCSChangePin to work on currently opened cellview.
It expects you to provide oll pin name and new name. It is a general pin name
change code. For example, to change pin, net and label from "IN" to "INP" call in CIW:
CCSChangePin("IN" "INP")

It will output:
Replaced pin IN with INP
t

*/
procedure(CCSchangeLabel(libName viewName @optional listOfCells)
               let((cv libId cellId cellList newNet)
                       libId = ddGetObj(libName)
                       if(!listOfCells then
                       cellList = libId~>cells
                               else
                               cellList = nil
                                      foreach(cellName listOfCells
                                      cellId = ddGetObj(libName cellName)
                                      cellList = append(list(cellId) cellList)
                                      );end foreach
                                      );end if
                               foreach(cell cellList
                                      foreach(view cell~>views  
                                      ;using views matching viewName variable.
                       if(view~>name == viewName && 
                       (cv = dbOpenCellViewByType(libName  cell->name view~>name "" "a")) then
                       printf("\nOpened view %L from cell %L of library %L for edit.\n" 
                              cv~>viewName cv~>cellName cv~>libName)
             
               foreach( term cv~>terminals
            term~>name = upperCase( term~>name )
            ;term~>name = lowerCase( term~>name )
            ;change terminals name
               ) ;end foreach
                  
               foreach( net cv~>nets
                newNet = dbMakeNet(cv upperCase(net~>name))
                ;newNet = dbMakeNet(cv lowerCase(net~>name))
                dbMergeNet(newNet net)
                foreach( fig newNet~>figs
                ;foreach( fig net~>figs
                    when( fig~>objType == "label"
                        fig~>theLabel = upperCase(fig~>theLabel )
                        ;fig~>theLabel = lowerCase(fig~>theLabel )
                        ; change the label attached with nets
                    ) ; end when
                ) ;end foreach
               ) ; end foreach

    dbCheck(cv)
    dbSave(cv)
dbClose(cv)
);end if
    );end foreach view
    );end foreach cell
           ddReleaseObj(libId)
    );let
    printf("Job Done...\n")
    );proc

procedure(CCSChangePin(oldName newName)
let((cv netId oldTerm)
  cv=geGetWindowCellView()
  oldTerm=car(setof(x cv~>terminals x~>name==oldName))
    if(dbFindNetByName(cv newName) then
       netId=dbFindNetByName(cv  newName)
    else
       netId=dbMakeNet(cv newName)
      ) ;if
  if(oldTerm then
   oldTerm~>name=newName
   dbMergeNet(netId oldTerm~>net)
  foreach(pin oldTerm~>pins
    foreach(child pin~>fig~>children
      child~>theLabel=newName
     ) ;foreach child
    ) ;foreach pin
   printf("\n Replaced pin %s with %s" oldName newName)
   else
   printf("\n Pin %s not found" oldName)
   );if 
   );let
  );procedure
