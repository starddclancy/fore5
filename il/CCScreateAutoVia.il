/*******************************************************************************
*  DISCLAIMER: The following code is provided for Cadence customers to use at  *
*   their own risk. The code may require modification to satisfy the           *
*   requirements of any user. The code and any modifications to the code may   *
*   not be compatible with current or future versions of Cadence products.     *
*   THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, INCLUDING WITHOUT     *
*   LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED WARRANTIES OF MERCHANTABILITY *
*   OR FITNESS FOR A PARTICULAR USE.                                           *
*******************************************************************************/
;;---------------------------- From here - CCScreateAutoVia.il--------------------
procedure(CCSmyCreateAutoVia(cvId point)
let( ()
   hiRegTimer("
   hiGetCurrentForm()->viaMode->value= \"Auto\"
   hiGetCurrentForm()->rodAutoName->value= t
   hiToggleEnterForm(hiGetCurrentForm() )
   " 2)
  preXY(point)
  finishEnterFun()
  leHiCreateVia()
);let
);procedure CCSmyCreateAutoVia
procedure(CCScreateAutoVia(point @key (cvId geGetEditCellView()) )
let( ()
     unless(cvId && cvId~>objType=="cellView"
       error("Please pass a valid cellview ID\n")
       );unless
     hiRegTimer("finishEnterFun()" 4)
     CCSmyCreateAutoVia(cvId point)
 );let
);procedure CCScreateAutoVia
;;------------------------------ Till here ---------------------------------------