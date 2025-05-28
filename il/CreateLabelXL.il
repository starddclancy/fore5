procedure(CreateLabelXL()
let((cv objs origin name label)
cv = geGetSelSet()
objs = cv ~> instances
foreach(obj objs
otigin = centerBox(obj~>bBox)
name = obj ~> name
label = dbCreateLabel(cv list("TXT" "ttxt") origin name "centerCenter" "R0" "roman" 0.2)
leAttachFig(label obj)
);foreach
);let
);proc

hiSetBindKey("Layout" "<Key>KP_3" "CreateLabelXL()")