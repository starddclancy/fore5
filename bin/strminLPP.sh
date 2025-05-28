#!/bin/bash

export LIB = $1
export CELL = $2
export VIEW = $3

if [[ "$#" -ne 3 ]]; then
    echo -e "\nUSAGE:\n"
    echo -e ". strminLPP.sh libName cellName viewName\n"
    return 1
fi
if [[ -z "$PROJDIR" ]]; then
    echo -e "\n $SCRPIT ERROR:Dont forget to setgeneric\n"
    return 1
fi
if [[ -z "$LIB" ]]; then
    echo -e "\nERROR: Library $LIB already exists!\n"
    return 1
fi
if [[ -z "$CELL" ]]; then
    echo -e "\nERROR: Cell $CELL already exists!\n"
    return 1
fi
if [[ -z "$VIEW" ]]; then
    echo -e "\nERROR: View $VIEW already exists!\n"
    return 1
fi

#####################################################
###   Streamout GDS

# strout \
#         -library $LIB \
#         -strmFile $CELL.gds \
#         -topCell $CELL \
#         -view $VIEW \
#         -enableColoring
#
#
### Not needed for small macros
###      -refLibList 'XST_CDS_LIB' \


######################################################
### Streanin GDS

LPPLIB = ${LIB}_lpp
strmin \
        -library $LPPLIB \
        -strmFile $CELL.gds \
        -topCell $CELL \
        -view $VIEW \
        -attachTechFileOfLib tech2 \
        -layermap $layermapFile
    
    ## Not needed for small macros
    ## -refLibList 'XST_CDS_LIB' \
    ## -cellMap $CELLMAPFILE
    ## -propMap 'XST_AUTO_PM'
    # Still need via mapping



    ##########################################################

# lyr lyrPurpose lryNumber datatype maskColor lockState

### MPT example:

#m1 drw 1 0
#m1 drw 1 1 maskColor locked
#m1 drw 1 2 maskColor unlocked
#m1 drw 1 3 maskColor locked
#m1 drw 1 4 maskColor unlocked


# v1 drawing 2 0 cut CUTSIZE:0.03:0.03

### LPP example:
 #m1 drw 1 0
 #m1 e1 1 1 