#!/bin/bash

export LIB = $1
export CELL = $2

export RUNDIR = $WORKDIR/lvs/$CELL
cd $RUNDIR

icv_nettran -icv $CELL.net -outName $CELL.sp -outType spice

echo ".model brres R" >> $CELL.sp
echo ".model lvsm1res R" >> $CELL.sp
echo ".model lvsm2res R" >> $CELL.sp
echo ".model lvsm3res R" >> $CELL.sp
echo ".model lvsm4res R" >> $CELL.sp
echo ".model lvsm5res R" >> $CELL.sp
echo ".model efuse R" >> $CELL.sp
echo ".model dtdcap C" >> $CELL.sp
echo ".model dtcellcap C" >> $CELL.sp
echo ".model dtdcap_array C" >> $CELL.sp
echo ".model egncap C" >> $CELL.sp
echo ".model ugncap C" >> $CELL.sp
echo ".model vncap C" >> $CELL.sp
echo ".model dtmoatcap C" >> $CELL.sp

echo ".model bitie R" >> $CELL.sp

cd $WORKDIR

eval "cat << EOF
$($HOME/std_spiceIn.params)
EOF" > $RUNDIR/spiceIn.params
cp $HOME/sch0pts_spiceIn.params $WORKDIR/.

cd $WORKDIR

spiceIn -param $RUNDIR/spiceIn.params -noasg
chmod -R +x $WORKDIR/$LIB/*/*/*

#cd $RUNDIR