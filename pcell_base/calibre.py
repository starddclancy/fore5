#!/usr/bin/python3.10
from base import *

class calibre:
    def __init__(self):
        self.moveOriToZero = "moveOriginToZero.tcl"
    def calibredrc(self, rulefile = None , layoutSystem = Nonne, layoutPath = None, oasFile = None, cellName = None, outPath = None, technode = None):
        print(technode)
        if technode == "28spp
            rulefile = "28spp.calibredrc"