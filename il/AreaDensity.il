procedure(AreaDensity()
let((cv tech BOX Density layers layerList)
cv=geGetEditCellView()
tech=techGetTechFile(cv)
layerList = leGetValidLayerList(tech)
layers=nil
foreach(layer layerList
	if(leIsLayerVisible(layer) == t
	then
	layers=append1(layers layer) 
	);if
);foreach
BOX=enterBox()
Box=list(geWindowToEditPoint(hiGetCurrentWindow() xCoord(Box))
	geWindowToEditPoint(hiGetCurrentWindow() yCoord(Box)))
BOX=list(car(BOX) xCoord(car(BOX)):yCoord(cadr(BOX)) cadr(BOX) xCoord(cadr(BOX)):yCoord(car(BOX)))
Density=leComputeAreaDensity(
	hiGetCurrentWindow()
	list(layers)
	?depth 31
	?region BOX
	)
println(Density)
);let
);proc

hiSetBindKey("Layout" "<Key>F5" "AreaDensity()")