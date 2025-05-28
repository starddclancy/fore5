/************************************
SCCS Info: @(#) CCScorner
*************************************/
/************************************
* DISCLAIMER: The following code is provided for Cadence customers to use at *
* their own risk. The code may require modification to satisfy the *
* requirements of any user. The code and any modifications to the code may *
* not be compatible with current or future versions of Cadence products. *
* THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, INCLUDING WITHOUT *
* LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED WARRANTIES OF MERCHANTABILITY *
* OR FITNESS FOR A PARTICULAR USE. 
**************************************/

procedure(CCScorner(corner_name @optional (sess axlGetWindowSession()) )
let((a b model_handle var_handle sdb sdb_corner varlist_handle var_list modellist_handle model_list )
unless(sess
error("Current window %L is not an adexl window, make sure that adexl window is current window\n" hiGetCurrentWindow())
)

sdb=axlGetMainSetupDB(sess) ;;getting sdb handle
sdb_corner=axlGetCorner(sdb, corner_name) ;; getting corner handle

modellist_handle=car(axlGetModels(sdb_corner )) ;;getting the handle for model list
model_list = car(cdr(axlGetModels(sdb_corner ))) ;; getting the list of model files
printf("%L\n",model_list)
foreach( model model_list
model_handle = axlGetModel( modellist_handle model )
b = axlGetEnabled( model_handle ) ;;getting variable value
if(b then printf("checked\t") else printf("unchecked\t"))
)
printf("\n") ;adding new line 
varlist_handle= car(axlGetVars( sdb_corner )) ;;getting the handle for variable list
var_list=car(cdr(axlGetVars( sdb_corner ))) ;; getting the list of variables including the temperature
foreach( var var_list
var_handle= axlGetVar( varlist_handle var )
a = axlGetVarValue( var_handle ) ;;getting variable value
printf("%s\t",a)
)
))
/******************** end *******************/
