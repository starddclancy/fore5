# Usage: initSpectreSim.sh lib cv
mylib = $1
mycell = $2

#;;CREATE DIRECTORIES, LINK SIM SPACE
mkdir -p $WORKDIR/SIM/$mycell/{netSpice, spice}
mkdir -p $SCRATCHDIR/$USER/sim/$mycell/spice/RAWOUT
ln -s $SCRATCHDIR/$USER/sim/$mycell/spice/RAWOUT $WORKDIR/SIM/$mycell/spice/ .


[[ ! -e $WORKDIR/sim/$mycell/netSpice/si.env ]] && sed -e "s/libnametemp/$mylib/" -e "s/cellnametemp/$mycell/" $INITENVDIR/model/RUNFILES/spiceNet/si.env > $WORKDIR/sim/$mycell/netSpice/si.env
ln -s $INITENVDIR/.simrc $WORKDIR/sim/$mycell/netSpice/.simrc

#;; NETLIST DESIGN AND LINK NETLIST.SCS to NETLIST
ln -s $WORKDIR/sim/$mycell/netSpice/netlist $WORKDIR/sim/$mycell/spice/netlist


#;;COPY SIM FILES OVER, BUT NOT IF THEY ALREADY EXIST
cp -n $INITENVDIR/model/RUNFILES/spiceSim/files $WORKDIR/sim/$mycell/spice/.
cp -n $INITENVDIR/model/RUNFILES/spiceSim/run $WORKDIR/sim/$mycell/spice/.
cp -n $INITENVDIR/model/RUNFILES/spiceSim/run.meas $WORKDIR/sim/$mycell/spice/.
cp -n $INITENVDIR/model/RUNFILES/spiceSim/run.prode $WORKDIR/sim/$mycell/spice/.
#cp -n $INITENVDIR/model/RUNFILES/spiceSim/run.sim $WORKDIR/sim/$mycell/spice/.

#;;ADD MODELS to run.sim, PUT RUN.SIM into /tmp
sed -e "s#projectnametemp#$PROJ#" $INITENVDIR/model/RUNFILES/spiceSim/run.inp > $WORKDIR/sim//$mycell/spice/run.inp