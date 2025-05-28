/********************************************************************
* DISCLAIMER: The following code is provided for Cadence customers *
* to use at their own risk. The code may require modification to   *
* satisfy the requirements of any user. The code and any    *
* modifications to the code may not be compatible with current or  *
* future versions of Cadence products.   *
* THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, INCLUDING   *
* WITHOUT LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED WARRANTIES  *
* OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE. *
********************************************************************/

;   Description   : This code will find an instance CDF parameter
;                    for a given instance cellName and change to a new value in all the schematic of the library
;
;   How to Run      :e.g. 
;                    CCSchangeParamInLib("testLib" "schematic" "nmos1v" "model" "nch") 

;                                       Where:

;                                        testLib    - library name
;                  schematic  - view name
;                  nmos1v        - instance cellName
;                  model      - parameter name
;                  nch        - new value
;
;   Tested in      : IC618
;   SKILL Lint Score (Max=100) : 100

procedure(CCSchangeParamInLib(libname viewname findInstCellName paramName newValue "tttttg")
    let((cv libId)
    libId=ddGetObj(libname)
    foreach(cell setof(sch libId~>cells   member("schematic" sch~>views~>name))
     cv = dbOpenCellViewByType(libname cell~>name viewname nil "a")
   ; find instance param
    foreach(inst cv~>instances
   ; find instance param
      if(inst~>cellName==findInstCellName
         then
     printf("Inst %s  %s\n" inst~>name inst~>cellName)
     foreach(param cdfGetInstCDF(inst)~>parameters
        if( param~>name == paramName      then
          printf("           %s [old]: %L\n" param~>name param~>value)
          param~>value = newValue
          printf("           %s [new]: %L\n" param~>name param~>value)
        );if
     ) ;foreach parameter
      );if
   );foreach instance
   schCheck(cv)
   dbSave(cv)
   dbClose(cv)
);foreach cell
) ;let
); end procedure CCSchangeParamInLib

/*****************************/
