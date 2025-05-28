/*************************************************************************
* DISCLAIMER: The following code is provided for Cadence customers       *
* to use at their own risk. The code may require modification to         *
* satisfy the requirements of any user. The code and any modifications   *
* to the code may not be compatible with current or future versions of   *
* Cadence products. THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, *
* INCLUDING WITHOUT LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED         *
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.         *
*************************************************************************/
procedure(CCSchgPinDirMaster(sourceLibName sourceCellName pinList newDirection)
let((cv cv_sym cellId pin_id pin_cell)
case(newDirection
    ("input" pin_cell="ipin")
    ("output" pin_cell="opin")
    ("inputOutput" pin_cell="iopin")
    (t error("Invalid direction %L specified, valid directions are input, output, inputOutput\n" newDirectio
n))
    ) ;case
cv_sym=dbOpenCellViewByType("basic" pin_cell "symbol" "schematicSymbol" "r")
cv = dbOpenCellViewByType(sourceLibName sourceCellName "schematic" "schematic" "a")
foreach(pin pinList
        pin_id=dbFindTermByName(cv pin)
        if(pin_id
            then
            printf("found %L pin %L in cell %L \n" pin_id~>direction pin sourceCellName)
            pin_id~>direction=newDirection
                foreach(pin1 pin_id~>pins
                    pin1~>fig~>master=cv_sym
                    )
            else
            printf("pin %L does not exist in cell %L \n" pin sourceCellName)
                   ) ;end of if
                   ) ;end of foreach
         dbSave(cv)
         dbClose(cv)
                 
  ) ; end of let
) ;end of procedure
;CCSchgPinDirMaster("mylib" "mycell"  list("A" "Z" "ZX") "input")