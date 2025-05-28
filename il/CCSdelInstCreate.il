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
USAGE:
======

This SKILL code runs on all the schematic views of a library and finds if
instances of a particular device or cell has been used or not. If they are
found then they need to be replaced with a new cell of a new library.
List of cell and its mapping to new cell has to be provided via deviceMapList.
For example:
deviceMapList='(("nmos1v" ("newRefLib" "nmos2v")) ("pmos1v" ("newRefLib" "pmos2v")))

In above example, nmos1v is supposed to be swapped with newRefLib nmos2v cell.
pmos1v is supposed to be swapped with newRefLib pmos2v cell.

The code copies old instance transform (placement info) and important properties
which needs to be paased on to new cell. And then it copies the old property 
values to new properties. The old and new property mapping is supposed to be
provided via propMapList.
For example:
propMapList='(("L" "l") ("W" "w") ("M" "m")) 

In the above list, value of property "L" is supposed to be copied to "l".
value of property "W" is supposed to be copied to "w".
value of property "M" is supposed to be copied to "m".

Load the SKILL code in CIW:
load "CCSdelInstCreate.il"

Run in CIW:
CCSdelInstCreate("MYLIB")


*/


procedure( CCSdelInstCreate(library @optional
;; Modify device list as per your primitive devices
( deviceMapList '(("nmos" ("OALIB" "nmos4"))  ("pmos" ("OALIB" "pmos4"))))
;; Modify propMapList as per the properties you want to copy
	(propMapList '(("l" "L") ("w" "W") ("m" "m")) )
	 "tll")   
let((cv cellname name transform libId instId deviceList deviceTable propTable)

libId=ddGetObj(library)
unless(libId error("Specified library: %s does not exists, cannot proceed!\n" library))

deviceTable=makeTable("deviceTable")
foreach(dev deviceMapList 
	deviceTable[car(dev)]=cadr(dev)
	deviceList=cons(car(dev) deviceList)
	)

propTable=makeTable("propTable")
foreach(cellId libId~>cells
;; Check if the cell has schematic view
	if(exists(x cellId~>views~>name (x=="schematic"))
		then
printf("Operating on Lib: %s Cell:%s View: schematic\n" library cellId~>name )
		cv=dbOpenCellViewByType(library cellId~>name "schematic"  "schematic"  "a")
;; Check if cellview has the instances of given device
				foreach(inst cv~>instances
					if(member(inst~>cellName deviceList) then
					transform=inst~>transform
					name=inst~>name
				 	cellname=inst~>cellName

;; Populate old property values to table
/*
					foreach(propList propMapList
					propTable[car(propList)]=dbFindProp(inst car(propList))~>value
						) ;foreach
*/
					cdfId=cdfGetInstCDF(inst)
					foreach(propList propMapList
					propTable[car(propList)]=cdfFindParamByName(cdfId car(propList))~>value
						) ;foreach

;; Delete old instance
					dbDeleteObject(inst)

;; Create new instance
		instId=dbCreateInstByMasterName(cv car(deviceTable[cellname])
			cadr(deviceTable[cellname])
				"symbol" name 
				car(transform)
				cadr(transform) )

;; Polpulate the inst parameter values from prop table
		foreach(propList propMapList
			dbSet(instId propTable[car(propList)] cadr(propList))
			) 
							) ;if member
							) ;foreach inst

/* To check and save the cellview uncomment below line */
	 	 ; if(dbIsCellViewModified(cv) then schCheck(cv) dbSave(cv))
		) ;if
	) ;foreach
t
  );let
);proc

