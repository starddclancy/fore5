import os
form base import *
import pandas as pd
class virtuoso:
    def __init__(self):
        pass
    def virImportOasis(self, libName, filePath, attachLib):
        createDir("LOG")
        logFile = "%s.log"  % (libName)
        cml = "oasisin -library %s -oasisFile '%s' - attachTechFileOfLib '%s' -logFile './LOG/%s'" % (libName, filePath, attachLib, logFile)
        os.system(cml)
    def virExportOasis(self, libName, cellName, outPath, layMap, withdate = None):
        crteateDir(outPath)
        date = getDate()
        if withdate:
            filePath = outPath + "/" + cellName + "_" + date + ".oas"
        else:
            filePath = outPath + "/" + cellName + ".oas"
        logFile = "%s/%s_ex.log"%(outPath, cellName)
        cml = "oasisout -library '%s' -oasisFile '%s' -topcell '%s' -view 'layout' -logFile '%s' -layerMap '%s' -autoGenOASISLayerName"%(libName, filePath, cellName, logFile, layMap)
        print("$s\n"%(cml))
        os.system(cml)
        print("oasis export %s %s ready\n"%(libName, cellName))


    def virCreateTestPattern(self, excel, sheettype, pcellLib, pcellName, patternLib, patternName, space = 510, layersubcut = None):
        dexcel = pd.read_excel(excel, header = 0, sheet_name = sheettype, na_filter = False)
        dtype = pd.read_excel(excel, header = 0, sheet_name = "type")
        dictParam = dtype.to_dict(orient = "dict")

        if layersubcut:
            subcut = 'dbCreateRect(cv list("%s" "drawing") instId~>bBox\n)'%(layersubcut)
        else:
            subcut = ""
        paramArgs = ""
        paramArgs2 = ""
        paramInst = "list(\n"
        for col in dtype.columns.values:
            paramArgs += '%s'&(col)
            paramArgs2 += '"%s" '%(col)
        for col in dtype.columns.values:
            paramInst += 'list("%s" "%s" %s)\n'%(col, dictParam[col][0], col)
        paramInst += ")\n"
        callFunc = "procedure(callInst(cv libName cellName viewType index orix oriy &s)\n let((instId instCDF paramId)\n"%(paramArgs
        callFunc += 'println(index)\ninstId = dbCreateParamInstByMasterName(cv libName cellName viewType get_pname(concat(cellName index)) (orix:oriy) "R0" 1 %s)\n'%(paramInst)
        callFunc += """ instCDF = cdfGetInstCDF(instID)
                           cdfgData = instCDF
                           foreach(param list(%s)
                           paramId = cdfFindParamByName(instCDF param)
                           when(paramId ~> callback evalstring(apramId ~> callback)
                               );foreach
                               %s
                           );let
                           """%(paramArgs2, subcut)
        callFunc += ");procedure\n"
        callPattern = """ libName = "%s"
        cellName = "%s"
        viewType = "layout"
        cv = dbOpenCellViewByType("%s" "%s" "layout" "maskLayout" "w")
        """%(pcellLib, pcellName, patternLib, patternName)
            for instNum in dexcel.index:
                dtmp = dexcel.loc[instNum]
                paramTmp = ""
                orix = instNum%10*space
                oriy = instNum//10*space
                for valuue, param in zip(dtmp.values, dtype.columns):
                    if dictParam[param][0] in ["boolean","int", "float"]:
                        paramTmp += '%s ' % (value)
                    else:
                        paramTmp += '"%s"'%(value)
                callPattern += "callInst(cv libName cellName viewType %s %s %s %s)\n"%(instNum, orix, oriy, paramTmp)
                callPattern +- "dbSave(cv)\n dbClose(cv)\n"
                return callFunc+callPattern

def virCreateTestPatternSch(self, excel, sheettype, pcellLib, pcellName, patternLib, patternName):
    dexcel = pd.read_excel(excel, header = 0, sheet_name = sheettype)
    dtype = pd.read_excel(excel, header = 0, sheet_name = "type")
    dictParam = dtype.to_dict(orient = "dict")
    #create schematic procedure
    paramArgs = ""
    paramArgs2 = ""
    paramInst = "list(\n"
    for col in dtype.columns.values:
        paramArgs += '%s'%(col)
        paramArg2 += '"%s"'%(col)
    for col in dtype.columns.values:
        paramInst += 'list("%s" "%s" %s)\n'%(col, dictParam[col][0], col)
    paramInst += ")\n"
    callFunc1 = "procedure(callInst(cv libName cellName viewType index orix oriy &s)\n let((instId instCDF paramId)\n"%(paramArgs)