procedure(testEditMode()
if(geGetEditCellView() ~> mode == "r"
then hiDisplayMenu(hiCreateSimpleMenu(
'menu "" list("ReadOnly!!!\n" "ReadOnly!!!\n" "ReadOnly!!!\n") list("")))
break()
);if
);proc