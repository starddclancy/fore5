#!/bin/bash

# Script called by $PROJDIR/SKILL/sim.il

#Usage: initVerilogSim.sh lib cv

export LIB = $1
export CELL = $2

export tool = verilog
export NETDIR = $WORKDIR/sim/$CELL/netV
export SIMDIR = $WORKDIR/sim/$CELL/$tool
export SIMOUT = xcelium.D

set -o noclobber

### Netlist dir setup
mkdir -p $NETDIR
 if [ ! -e $NETDIR/si.env ];then
     sed -e "s/libnametemp/$LIB/" -e "s/cellnametemp/$CELL/" $INITENVDIR/model/RUNFILES/${tool}Net/si.env > $NETDIR/si.env
 fi
 if [! -e $NETDIR/.simrc ]; then
     ln -s $INITENVDIR/.simrc $NETDIR/.simrc
 fi
 if [! -e $NETDIR/run ]; then
     eval "cat << EOF
 $(<$INITENVDIR/model/RUNFILES/${tool}Net/run)
 EOF" > $NETDIR/run
 fi
 .$NETDIT/run
### Simulation dir setup
mkdir -p $SIMDIR
mkdir -p $INITENVDIR/scratch/$USER/sim/$CELL/$tool/$SIMOUT
rm -rf $SIMDIR/$SIMOUT
ln -sf $INITENVDIR/scratch/$USER/sim/$CELL/$tool/$SIMOUT $SIMDIR/$SIMOUT
if [! -e $SIMDIR/netlist.v ]; then
    ln -s $INITENVDIR/netlist $SIMDIR/netlist.v
fi
if [! -e $SIMDIR/run ]; then
    eval "cat << EOF
 $(<$INITENVDIR/model/RUNFILES/${tool}Sim/run)
 EOF" > $SIMDIR/run
 chmod +x $SIMDIR/run
fi

### Testbench setup
if [! -e $SIMDIR/testbench.v ]; then
    eval cat << EOF >> $SIMDIR/testbench.v

 // Verilog stimulus file.

 \`timescale 1ns / 1ps
 module testbench();
 EOF
    grep -w ^inputOutput $INITENVDIR/pinInfo.txt | cut -d'' -f2 \
    | tr ',' '\n' \
    | sed -e 's/^/\twire /' -e 's/$/;/' \
    >> $SIMDIR/testbench.v
    echo -e "\-n" >> $SIMDIR/testbench.v

    grep -w ^input $INITENVDIR/pinInfo.txt | cut -d'' -f2 \
    | tr ',' '\n' \
    | sed -e's/^/\treg /' -e's/$/;/' \
    >> $SIMDIR/testbench.v
    echo -e "-\n" >> $SIMDIR/testbench.v

    grep -w ^inputOutput $INITENVDIR/pinInfo.txt | cut -d'' -f2 \
    | tr ',' '\n' \
    | sed 's/<.*>//g' | sort -u \
    | sed -e's/^/\tassign /' -e's/$/ = 0;/' \
    >> $SIMDIR/testbench.v
    
    cat << EOF >> $SIMDIR/testbench.v
initial begin
EOF
    grep -w ^input $INITENVDIR/pinInfo.txt | cut -d'' -f2 \
    | tr ',' '\n' \
    | sed -e 's/^/\t/' -e's/$/ = 0;/' \
    >> $SIMDIR/testbench.v

    cat << EOF >> $SIMDIR/testbench.v
    #10
    $finish;
    end // initial begin

EOF

    # Add top level module to netlist
    sed -n "/module[[:space:]][[:space:]]*$CELL[[:space:]]/,/;/p" \ 
    $SIMDIR/netlist.v \
    | sed -e "s/module[[:space:]]$CELL/$CELL I$CELL/g"  \
    >> $SIMDIR/testbench.v

    cat << EOF >> $SIMDIR/testbench.v
    initial begin
    \$dumpfile("testbench.vcd");
    \$dumpvars(0);
    \$dumpon;
    \$dumpall;
    end
endmodule
EOF
fi  