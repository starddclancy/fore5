#!/bin/bash

rm -f si.log
si . -batch - cdslib cds.lib -command netlist \ 
    | tee si.log