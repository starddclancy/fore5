procedure(AutoCutBus(bb)
let((objs cv Hlist Vlist points pointsNum startPoint endPoint x0 xn y0 yn point_H_0 point_H_n point_V_0 point_V_n temp1 temp2 temp3 temp4 min RefPoint Num_H Num_V pair_Hlist pair_Vlist pair_H pair_V length_H length_V length_Min tempH tempV)
cv = geGetEditCellView()
objs = geGetSelSet()
;****************************************************************
;convert pathSeg to path
objs = setof(x objs x~>objType == "path" || x~>objType == "pathSeg")
Hlist = list()
Vlist = list()
foreach(obj objs
	if(obj ~> objType == "pathSeg" then
	leConvertShapeToPolygon(obj)
	leConvertPolygonToPath(obj)
	);if
;****************************************************************
;split objs for Horizontal or Vertical
points = obj ~> points
pointsNum = obj ~> nPoints
startPoint = nth(0 points)
endPoint = nth(pointsNum-1 points)
x0 = xCoord(startPoint)
y0 = yCoord(startPoint)
xn = xCoord(endPoint)
yn = yCoord(endPoint)
	if(abs(x0-xn) > abs(y0-yn)
	then Hlist = append1(Hlist obj)
	else Vlist = append1(Vlist obj)
	);if
);foreach
;****************************************************************
;get reference points
Num_H = car(Hlist) ~> nPoints
Num_V = car(Vlist) ~> nPoints
point_H_0 = nth(0	car(Hlist) ~> points)
point_H_n = nth(Num_H-1	car(Hlist) ~> points)
point_V_0 = nth(0	car(Vlist) ~> points)
point_V_n = nth(Num_V-1	car(Vlist) ~> points)
temp1 = expt(xCoord(point_H_0) 2) + expt(yCoord(point_V_0) 2)
temp2 = expt(xCoord(point_H_0) 2) + expt(yCoord(point_V_n) 2)
temp3 = expt(xCoord(point_H_n) 2) + expt(yCoord(point_V_0) 2)
temp4 = expt(xCoord(point_H_n) 2) + expt(yCoord(point_V_n) 2)
min = min(temp1 temp2 temp3 temp4)
if(min = temp1 then RefPoint = list(xCoord(point_V_0) yCoord(point_H_0)));if
if(min = temp2 then RefPoint = list(xCoord(point_V_n) yCoord(point_H_0)));if
if(min = temp3 then RefPoint = list(xCoord(point_V_0) yCoord(point_H_n)));if
if(min = temp4 then RefPoint = list(xCoord(point_V_n) yCoord(point_H_n)));if
;****************************************************************
;get object points list
pair_Hlist = list()
foreach(one Hlist
Num_H = one ~> nPoints
point_H_0 = nth(0 one ~> points)
point_H_n = nth(Num_H-1 one ~> points)
temp1 = expt(xCoord(point_H_0)-xCoord(RefPoint) 2) +expt(yCoord(point_H_0)-yCoord(RefPoint) 2)
temp2 = expt(xCoord(point_H_n)-xCoord(RefPoint) 2) +expt(yCoord(point_H_n)-yCoord(RefPoint) 2)
if(temp1 < temp2 then pair_H = list(one point_H_0 0) else pair_H = list(one point_H_n Num_H));if
pair_Hlist = append1(pair_Hlist pair_H)
);foreach
pair_Vlist = list()
foreach(one Vlist
Num_V = one ~> nPoints
point_V_0 = nth(0 one ~> points)
point_V_n = nth(Num_V-1 one ~> points)
temp3 = expt(xCoord(point_V_0)-xCoord(RefPoint) 2) +expt(yCoord(point_V_0)-yCoord(RefPoint) 2)
temp4 = expt(xCoord(point_V_n)-xCoord(RefPoint) 2) +expt(yCoord(point_V_n)-yCoord(RefPoint) 2)
if(temp3 < temp4 then pair_V = list(one point_V_0 0) else pair_V = list(one point_V_n Num_V));if
pair_Vlist = append1(pair_Vlist pair_V)
);foreach
;****************************************************************
;sorting
length_H = length(pair_Hlist)
length_V = length(pair_Vlist)
length_Min = min(length_H length_V)
declare(ppa[length_H])
declare(ppb[length_V])
for(i 0 length_H-1
ppa[i] = nth(i pair_Hlist)
);for
for(i 0 length_V-1
ppb[i] = nth(i pair_Vlist)
);for
for(i 0 length_H-1
	for(j i length_H-1
		if(yCoord(cadr(ppa[i])) > yCoord(cadr(ppa[j])) then
		tempH = ppa[i]
		ppa[i] = ppa[j]
		ppa[j] = tempH
		);if
	);for
);for
for(i 0 length_V-1
	for(j i length_V-1
		if(xCoord(cadr(ppb[i])) > xCoord(cadr(ppb[j])) then
		tempV = ppb[i]
		ppb[i] = ppb[j]
		ppb[j] = tempV
		);if
	);for
);for
for(i 0 length_Min-1
if(bb == 1 then
cutMetal(ppa[i] ppb[i])
else
cutMetal(ppa[i] ppb[length_Min-1-i])
);if
);for
);let
);proc

procedure(cutMetal(pairA pairB)
let((cv widthA widthB pointsA pointsB new_pointA new_pointB)
widthA = car(pairA) ~> width
widthB = car(pairB) ~> width
pointsA = car(pairA) ~> points
pointsB = car(pairB) ~> points
;RefPoint = list(xCoord(cadr(pairA)) yCoord(cadr(pairB)))
if(car(reverse(pairA)) == 0 then
	if(xCoord(cadr(pairA)) < xCoord(nth(1 pointsA)) then
	new_pointA = list(xCoord(cadr(pairB))-width/2 yCoord(cadr(pairA)))
	else
	new_pointA = list(xCoord(cadr(pairB))+width/2 yCoord(cadr(pairA)))
	);if
car(pairA) ~> points = cons(new_pointA cdr(pointsA))
else
	if(xCoord(cadr(pairA)) < xCoord(nth(1 reverse(pointsA))) then
	new_pointA = list(xCoord(cadr(pairB))-widthB/2 yCoord(cadr(pairA)))
	else
	new_pointA = list(xCoord(cadr(pairB))+widthB/2 yCoord(cadr(pairA)))
	);if
car(pairA) ~> points = cons(new_pointA cdr(reverse(pointsA)))
);if
if(car(reverse(pairB)) == 0 then
	if(yCoord(cadr(pairB)) < yCoord(nth(1 pointsB)) then
	new_pointB = list(xCoord(cadr(pairB)) yCoord(cadr(pairA))-widthA/2)
	else
	new_pointB = list(xCoord(cadr(pairB)) yCoord(cadr(pairA))+widthA/2)	
	);if
car(pairB) ~> points = cons(new_pointB cdr(pointsB))
else
	if(yCoord(cadr(pairB)) < yCoord(nth(1 reverse(pointsB))) then
	new_pointB = list(xCoord(cadr(pairB)) yCoord(cadr(pairA))-widthA/2)
	else
	new_pointB = list(xCoord(cadr(pairB)) yCoord(cadr(pairA))+widthA/2)
	);if
car(pairB) ~> points = cons(new_pointB cdr(reverse(pointsB)))
);if
);let
);proc

hiSetBindKey("Layout" "<Key>KP_4" "AutoCutBus(1)")
hiSetBindKey("Layout" "<Key>KP_5" "AutoCutBus(2)")