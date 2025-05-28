#!/bin/bash

rm -f si.log
si . -batch - cdslib cds.lib -command nl \ 
    | tee si.log