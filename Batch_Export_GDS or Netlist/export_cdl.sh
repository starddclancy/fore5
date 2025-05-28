#!/bin/bash
#--------------------------
# Program  : export_cdl.sh
# Language : Bash
# Author   : YEUNGCHIE
# Version  : 2022.04.03
#--------------------------
HelpDoc(){
    cat <<EOF
-------------------------------------------------
Export CDL ( Circuit Description Language ) File
-------------------------------------------------
Usage: export_cdl -cdslib cdslibFile -lib libName -cell cellName [ OPTIONS ]
 
    -cdslib     Path of cds.lib file
    -lib        Schematic top cell libName
    -cell       Schematic top cell cellName
    -view       Schematic top cell viewName ( Default: schematic )
    -file       Output netlist file name    ( Default: ./<cellName>.cdl )
    -include    Include subckt file name
    -order      Netlisting Type Connection By Order ( The default is By Name )
    -h, -help   Display this help
 
Examples:   export_cdl  -cdslib ./cds.lib  -lib Xeon  -cell X999  -include ./subckt.cdl
 
Output:     Netlist file: X999.cdl
EOF
}
 
for a in $@; do
    if [[ $a =~ ^-+h(elp)? ]]; then
        HelpDoc >&2
        exit 1
    fi
done
 
unset libName
unset cellName
unset viewName
unset netlistFile
unset cdslibFile
unset includeFile
unset includeFiles
unset connType
 
viewName='schematic'
connType='ansCdlHnlPrintInst'
 
# 命令行参数分析
while [[ -n $1 ]]; do
    case $1 in
        -lib)       shift;  libName=$1                      ;;
        -cell)      shift;  cellName=$1                     ;;
        -view)      shift;  viewName=$1                     ;;
        -file)      shift;  netlistFile=$1                  ;;
        -cdslib)    shift;  cdslibFile=$1                   ;;
        -include)   shift;  includeFile="$includeFile $1"   ;;
        -order)     connType='ansCdlSubcktCall'             ;;
        *)
            echo "Invalid option - '$1'" >&2
            echo "Try -h or -help for more infomation." >&2
            exit 1
        ;;
    esac
    shift
done
 
# 参数检查
if [[ ! ( -n $cdslibFile && -n $libName && -n $cellName ) ]]; then
    ## 缺少必要参数时，打印 help 并退出
    HelpInfo >&2
    exit 1
elif [[ -f $cdslibFile ]]; then
    ## 将相对路径改为绝对路径
    cdslibDir=$(cd $(dirname $cdslibFile); pwd -P)
    fileName=$(basename $cdslibFile)
    cdslibFile="$cdslibDir/$fileName"
else
    ## 找不到 cds.lib 文件，打印报错
    echo "No such file - $cdslibFile" >&2
    echo "Try -h or -help for more infomation." >&2
    exit 1
fi
 
for f in $includeFile; do
    f=$(cd $(dirname $f); pwd -P)/$(basename $f)
    includeFiles="$includeFiles $f"
done
 
## 当网表文件名未定义时，设置默认文件名
if [[ -z $netlistFile ]]; then netlistFile="${cellName}.cdl" ; fi
 
runDir=$(dirname $netlistFile)
netlistFile=$(basename $netlistFile)
 
if [[ ! -w $runDir ]]; then
    echo "Cannot access run directory - $runDir" >&2
    exit 1
fi
 
# si.env 文件生成
cat > $runDir/si.env <<EOF
simLibName = "$libName"
simCellName = "$cellName"
simViewName = "$viewName"
simSimulator = "auCdl"
simNotIncremental = 't
simReNetlistAll = nil
simViewList = '("auCdl" "cdl" "schematic" "cmos_sch" "gate_sch" "cmos.sch" "gate.sch" "symbol")
simStopList = '("auCdl" "cdl")
simNetlistHier = t
hnlNetlistFileName = "$netlistFile"
resistorModel = ""
shortRES = 2000.0
preserveRES = 't
checkRESVAL = 't
checkRESSIZE = 'nil
preserveCAP = 't
checkCAPVAL = 't
checkCAPAREA = 'nil
preserveDIO = 't
checkDIOAREA = 't
checkDIOPERI = 't
checkCAPPERI = 'nil
simPrintInhConnAttributes = 'nil
checkScale = "meter"
checkLDD = 'nil
pinMAP = 'nil
preserveBangInNetlist = 'nil
shrinkFACTOR = 0.0
globalPowerSig = ""
globalGndSig = ""
displayPININFO = 't
preserveALL = 't
setEQUIV = ""
incFILE = "$includeFiles"
auCdlDefNetlistProc = "$connType"
EOF
 
# 运行 si
si $runDir -batch -command netlist -cdslib $cdslibFile
 
status=$?
 
# 删除中间文件
if [[ -f .stimulusFile.auCdl ]]; then rm -rf .stimulusFile.auCdl ; fi
if [[ -f si.env              ]]; then rm -rf si.env              ; fi
if [[ -f netlist             ]]; then rm -rf netlist             ; fi
if [[ -d ihnl                ]]; then rm -rf ihnl                ; fi
if [[ -d map                 ]]; then rm -rf map                 ; fi
 
exit $status