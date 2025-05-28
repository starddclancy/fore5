export LIB = $1
export CELL = $2

export tool = spectre
export NETDIR =  $WORKDIR/sim/$CELL/net
export SIMDIR = $WORKDIR/sim/$CELL/$tool
export SIMOUT = RAWOUT

set -o noclobber

### Netlist dir setup

mkdir -p $NETDIR
if [ ! -e $NETDIR/si.env ]; then
    sed -e "s/libnametemp/$LIB/g" -e "s/cellnametemp/$CELL/" \
    $INITENVDIR/model/RUNFILES/${tool}/si.env > $NETDIR/si.env
fi

if [ ! -e $NETDIR/.simrc ]; then
    ln -s $INITENVDIR/.simrc $NETDIR/.simrc
fi

if [ ! -e $NETDIR/run ]; then
    eval "cat << EOF
$(<$INITENVDIR/model/RUNFILES/${tool}/run)
EOF" > $NETDIR/run
    chmod +x $NETDIR/run
fi

.$NETDIR/run


### Simulation dir setup

mkdir -p $SIMDIR
mkdir -p $WORKDIR/scratch/$USER/sim/$CELL/$tool/$SIMOUT
rm -rf $SIMDIR/$SIMOUT
ln -sf $WORKDIR/scratch/$USER/sim/$CELL/$tool/$SIMOUT $SIMDIR/$SIMOUT

if [! -e $SIMDIR/netlist.scs ]; then
    ln -s $INITENVDIR/netlist $SIMDIR/netlist.scs
fi

if [! -e $SIMDIR/run ]; then
    eval "cat << EOF
$(<$INITENVDIR/model/RUNFILES/${tool}/run)
EOF" > $SIMDIR/run
    chmod +x $SIMDIR/run
fi

### Testbench

if [! -e $SIMDIR/run.inp ]; then
    eval "cat << EOF
$(<$INITENVDIR/model/RUNFILES/${tool}/run.inp)
EOF" > $SIMDIR/run.inp
fi

if [-e $WORKDIR/lvs/$CELL/$CELL.cdl ]; then
    sed -i "s#tempDUT#$(sed -n "/^\.SUBCKT[[:space:]][[:space:]]*$CELL[[:space:]]/,/\*\.PININFO/p" $WORKDIR/lvs/$CELL/$CELL.cdl | grep -v PININFO | sed -e "s/^\.SUBCKT[[:space:]][[:space:]]*$CELL/XDUT/" -e "s/$/ $CELL" | sed -e  :a -e '$!N;s/\n+/ /; ta' -e 'P;D')#" $SIMDIR/run.inp
fi

cp -n $INITENVDIR/model/RUNFILES/${tools}Sim/run.meas $SIMDIR/.
cp -n $INITENVDIR/model/RUNFILES/${tools}Sim/run.prode $SIMDIR/.

if [ ! -e $SIMDIR/run.sim ]; then
    grep -v tempStim $INITENVDIR/model/RUNFILES/${tool}/run.sim > $SIMDIR/run.sim\
    >> $SIMDIR/run.sim
    cat << EOF >> $SIMDIR/run.sim 

//--------------------------//
// Supplies
//--------------------------//

EOF

    grep -w ^inputOutput $INITENVDIR/pinInfo.txt | cut -d ' ' -f2 \
    | tr ',' '\n' \
    | grep -w -f $INITENVDIR/model/RUNFILES/spectreSim/pwr.sim \
    | while read node
    do
    echo "V$node $node 0 DC = 'p$node'" \
        | sed -e 's/</\\</' -e 's/>/\\>/g'
    done >> $SIMDIR/run.sim

    echo -e "\n" >> $SIMDIR/run.sim
    cat << EOF >> $SIMDIR/run.sim

//--------------------------//
// Input stimuli
//--------------------------//    

EOF

    grep -w ^inputOutput $INITENVDIR/pinInfo.txt | cut -d'' -f2 \
    | tr ',' '\n' \
    | grep -v -w -f $INITENVDIR/model/RUNFILES/spectreSim/pwr.sim \
    | while read node
    do
    echo "V$node $node 0 PWL (0, 0, 1n, 0, 1.1n, 'pVDD') \
        | sed -e's/</\\</' -e's/>/\\>/g'
    done >> $SIMDIR/run.sim

    echo -e "\n" >> $SIMDIR/run.sim

    grep -e "-n" >> $SIMDIR/run.sim

    grep -w ^input $WORKDIR/pinInfo.txt | cut -d'' -f2 \
    | tr ',' '\n' \
    | while read node
    do
    echo "V$node $node 0 PWL (0, 0, 1n, 0, 1.1n, 'pVDD') \
        | sed -e's/</\\</' -e's/>/\\>/g'
    done >> $SIMDIR/run.sim

    echo -e "\n" >> $SIMDIR/run.sim
fi #run.sim