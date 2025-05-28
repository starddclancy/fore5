#!/bin/bash 

export SCRIPT = createTree.sh
export LIB = $1
export TOPCELL = $2

if [[ "$#" -ne 2 ]]; then
    echo -e "\nUSAGE:\n"
    echo -e ". SCRIPT libName cellName\n"
    return 1
fi
if [[ -z "$LIB" ]]; then
    echo -e "\nERROR: Library $LIB already exists!\n"
    return 1
fi
if [[ -z "$TOPCELL" ]]; then
    echo -e "\nERROR: Topcell $TOPCELL already exists!\n"
    return 1
fi

. $PROJDIR/bin/projectrc generic
mkdir -p $WORKDIR/tree

#print all cells in layout
fastTree -lib $LIB -cell $TOPCELL -file tree/tree.$TOPCELL.lay.txt
rm -f $WORKDIR/cells.lay.tmp
cat tree/tree.$TOPCELL.lay.txt | sed 's/[[:space:]][[:space:]]*/\t/g' \
    | cut -f 2,3 | grep -w "^$LIB" | sort -u \
    | tee $WORKDIR/cells.lay.tmp
#print all cells in schematic
rm -f CDS.script.log
virtuoso -nograph -log CDS.script.log <</
load(strcat(myprojdir "SKILL/CCSschTree.il"))
schcv = dbOpenCellViewByType(getShellEnvVar("LIB") getShellEnvVar("TOPCELL") "schematic" "schematic" "r")
CCSschTree( ?cellView schev 
            ?port     op=outfile(strcat("tree/tree." getShellEnvVar("TOPCELL") ".sch.txt"))
close(op)
exit()
/