/*************************************************************************
* DISCLAIMER: The following code is provided for Cadence customers       *
* to use at their own risk. The code may require modification to         *
* satisfy the requirements of any user. The code and any modifications   *
* to the code may not be compatible with current or future versions of   *
* Cadence products. THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, *
* INCLUDING WITHOUT LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED         *
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.         *
*************************************************************************/

/*
Usage as following: Load the SKILL code in CIW window or through the .cdsinit file.

load("CCSmakeStackVia.il")

Examples:
; CCSmakeStackVia(layerList1 layerList2 pointList orientation @optional (cutRows nil) (cutColumns nil) (libName nil) (cellName nil) (viewName nil) )

; Place the via in the currently opened cellview.

; Specified cutRows and cutColumns as 4 4
CCSmakeStackVia( list("Poly" "drawing") list("Metal4" "drawing") list(5 5) "R0" 4 4)

; Or without cutRows and cutColumns
CCSmakeStackVia( list("Poly" "drawing") list("Metal4" "drawing") list(5 5) "R0")
 

Or

; In batch mode, specify the cellview details.

Example:
CCSmakeStackVia( list("Poly" "drawing") list("Metal4" "drawing") list(5 5) "R0" 4 4 "TestLib" "TestSlot" "layout")
*/
 

;----------------------------- CCSmakeStackVia.il -------------------------------------------

procedure(CCSmakeStackVia(layerList1 layerList2 pointList orientation @optional (cutRows nil) (cutColumns nil) (libName nil) (cellName nil) (viewName nil) "llltggggg")

let(( cvId tfId validVias layer1 layer2 viaNo viaId viaParams viaParamsNew )

;Get the cellview id where you want to place the via
if(and(libName cellName viewName) then
	if(!ddGetObj(libName cellName viewName) then
		error("%s cellView of cell %s->%s doesn't exists.\n" viewName libName cellName)
	else
		cvId    = dbOpenCellViewByType(libName cellName viewName "" "a")
	); if
else
	cvId    = geGetEditCellView()
); if libName cellName viewName

 
;Via param List
if(and(cutRows cutColumns) then
	viaParams       = list(list("cutRows" cutRows) list("cutColumns" cutColumns))
else
	viaParams       = nil
); if cutRows cutColumns

;Get the technology file id of the library that contains the definition of the via
tfId    = techGetTechFile(cvId)

; Find all the Valid Vias Names between bottomLayer and toplayer
layer1  = car(layerList1)
layer2  = car(layerList2)

validVias  = lxGetValidViaDefs(cvId nil layer1 layer2)
viaNo      = 0

;Place the via at the coordinate, and with orientation you want

	if(validVias then
	printf("Creating Stack Via for bottomLayer %L and toplayer %L.\n" layerList1 layerList2)

	foreach(via validVias
		viaId           = techFindViaDefByName(tfId car(via)~>name)

		if(viaId then
			viaNo           = viaNo + 1
			viaParamsNew    = lxComputeViaParams( viaId cvId nil viaParams)
			printf("\t%d.\tCreating %L Via of %L at %L with Orientation %s and Parameters %L.\n" viaNo viaId~>name viaId~>objType pointList orientation viaParamsNew)
			dbCreateVia(cvId viaId pointList orientation viaParamsNew )
		else
			warn("There is no such Via by name %s in Technology %s.\n" car(via)~>name tfId~>libName)
		); if viaId

	); foreach via

	else
	
	warn("There are no such Vias available in Technology %s for bottomLayer %L and toplayer %L.\n" tfId~>libName layerList1 layerList2)
	
	); if validVias
	
  dbSave(cvId)
  dbClose(cvId)
  printf("Done with Creation of Stacked Via\n")

); let
); procedure CCSmakeStackVia

;----------------------------------------------------------------------------------------------

 
