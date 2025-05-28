/*************************************************************************
* DISCLAIMER: The following code is provided for Cadence customers       *
* to use at their own risk. The code may require modification to         *
* satisfy the requirements of any user. The code and any modifications   *
* to the code may not be compatible with current or future versions of   *
* Cadence products. THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, *
* INCLUDING WITHOUT LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED         *
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.         *
*************************************************************************/

/* USAGE:
Load the SKILL code in CIW:
load "CCSrenameWithSuffix.il"

It defines a function CCSrenameWithSuffix. The arguments it expects are:

mylibName -> name of the library

suffix -> suffix to be appended ("_" will automaticlly attached ex: cell1_suffix1))

cellFile -> Name of file which has cell names to be renamed. By default it expects
list_cell file in current working directory with format like:

cell1
cell2
cell3 

To run the SKILL code, type in CIW:
CCSrenameWithSuffix("sourcelib" "suffix")

This will rename cells of library sourcelib with a suffix "_suffix". The code will
only act on cells specified in list_cell file.

If you want to specify cell names in a different file say "/home/user/mycellfile.txt"
then call in CIW:
CCSrenameWithSuffix("sourcelib" "suffix" "/home/user/mycellfile.txt")


If you want the SKILL code to add prefix instead of suffix, just change the line in code:

      newcellName = strcat(myCellName "_" suffix)

      with

      newcellName = strcat(suffix "_" myCellName) 
*/
 

procedure(CCSrenameWithSuffix(mylibName suffix @optional (cellFile "./list_cell"))
let((libId cellList newcellName templist)

templist=CCSreadCellFile(cellFile)

if(member(mylibName ddGetLibList()~>name)
	then
	libId = ddGetObj(mylibName)
	cellList = libId~>cells~>name
	else
	printf("Cannot find Library %L\\n" mylibName)
	);end if

foreach( myCellName templist
         if(member(myCellName cellList)
		then
	        newcellName = strcat(myCellName "_" suffix)

/* In case of prefix comment the above line and uncomment the below line */
		; newcellName = strcat(suffix "_" myCellName)


/* Validate that the new name does not exist in the specified file
   otherwise a name clash will happen */
           	unless(member(newcellName cellList)
	        printf("Renaming %s to %s \n", myCellName newcellName)
	        CCSRenameCell( mylibName myCellName newcellName)
		        );unless
		
		else
		warn("Cell %s does not exist in library %s, renaming not possible\n" 
				myCellName mylibName)
	        ) ;end if
	);foreach
t
);let
);procedure

/** Procedure to read the cell list file */

procedure(CCSreadCellFile(cellFileName)
let((inport word outlist)

unless(isFile(cellFileName)
	error("Either the specified file does not exists or specified
		 path is incorrect: %s\n" cellFileName)
	)

inport=infile(cellFileName)
outlist='()

;; Start reading file line by line
	while(fscanf(inport "%s" word)
	outlist=cons(word outlist)
		) ;while

printf("Number of Cells specified in file to be renamed:%d\n" length(outlist))
close(inport)

outlist
) ;let
)
 

/********************************************************************
By default CCSRenameCell updates the references only in the same library.

To have it perform updates in all the library, or only in the
newcell itself, use other switches mentioned in the commented
line below ccpRename(....) in below code.

Usage: CCSRenameCell("mylibrary" "my_existing_cell" "new_cell_name")

While renaming if destination cell ( new named cell ) already exists
then it will not do the renaming by default.

You may choose to overwrite an existing cell in such case by calling it like:
CCSRenameCell("mylibrary" "my_existing_cell" "new_cell_name" t)
*********************************************************************/

procedure( CCSRenameCell( libName cellName newCellName

                          @optional (overwrite  nil) "tttg")

let( ( srcSpec ovFlag destSrc )

	if(ddGetObj(libName cellName)
		 then       ;if cell is there
		srcSpec = gdmCreateSpec(libName cellName "" "" "CDBA")  
               
                  if(overwrite then ovFlag = 'TRUE   ; If overwrite is selected
                        else  ovFlag = 'FALSE
                    ) ; if

                  destSrc = gdmCreateSpec(libName newCellName "" "" "CDBA")
                  ccpRename(srcSpec destSrc ovFlag 'CCP_EXPAND_ALL

                  'CCP_UPDATE_DESTLIB_ONLY)

                  ;; Other flags are CCP_UPDATE_DESTLIB_ONLY and

                  ;; CCP_UPDATE_FROM_LIBLIST default: CCP_UPDATE_FROM_LIBLIST  

                else                                 ; source cell is missing

                    error("CCSRenameCell : Cell %s from lib %s does not exists\\n"

                               libName cellName ) ; error
                ) ; if

        ) ; let
) ; procedure
