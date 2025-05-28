#!/bin/bash
#--------------------------
# Program  : export_layout.sh
# Language : Bash
# Author   : YEUNGCHIE
# Version  : 2022.04.05
#--------------------------
HelpDoc(){
    cat <<EOF
-------------------------------------------------
Export Layout ( GDSII or OASIS ) File
-------------------------------------------------
Usage: export_layout -path cdslibDir -lib libName -cell cellName [ OPTIONS ]
 
    -path       Path where the cds.lib file is located
    -lib        Layout top cell libName
    -cell       Layout top cell cellName
    -view       Layout top cell viewName    ( Default: layout )
    -file       Output file name            ( Default: <cellName>.gds or <cellName>.oasis )
    -log        Log file                    ( Default: export_layout.log )
    -sum        Summary file
    -layermap   Specified the layermap file
    -oasis      Specified the file format is OASIS, and GDSII if not specified
    -h, -help   Display this help
 
Examples:   export_layout\\
                -path       \$project/work/
                -lib        Xeon
                -cell       X999
                -oasis
 
Output:     OASIS file - X999.oasis
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
unset file
unset path
unset logFile
unset sumCmd
unset mapCmd
unset OASIS
 
viewName='layout'
logFile='export_layout.log'
 
# 命令行参数分析
while [[ -n $1 ]]; do
    case $1 in
        -lib)       shift;  libName=$1                  ;;
        -cell)      shift;  cellName=$1                 ;;
        -view)      shift;  viewName=$1                 ;;
        -file)      shift;  file=$1                     ;;
        -path)      shift;  path=$1                     ;;
        -log)       shift;  logFile=$1                  ;;
        -sum)       shift;  sumCmd="-summaryFile $1"    ;;
        -layermap)  shift;  mapCmd="-layerMap $1"       ;;
        -oasis)     OASIS=1                             ;;
        *)
            echo "Invalid option - '$1'" >&2
            echo "Try -h or -help for more infomation." >&2
            exit 1
        ;;
    esac
    shift
done
 
# 记录当前路径
runDir=$(pwd -P)
 
# 参数检查
if [[ ! ( $path && $libName && $cellName ) ]]; then
    # 缺少必要参数时，打印 help 并退出
    HelpInfo >&2
    exit 1
elif [[ -d $path ]]; then
    cd $path
else
    # 找不到目标路径文件，打印报错
    echo "No such directory - $path" >&2
    echo "Try -h or -help for more infomation." >&2
    exit 1
fi
 
## 不同的文件格式
if [[ $OASIS ]]; then
    if [[ ! $file ]]; then file="${cellName}.oasis" ; fi
    command="oasisout -oasisFile $file"
else
    if [[ ! $file ]]; then file="${cellName}.gds" ; fi
    command="strmout -strmFile $file"
fi
 
command="$command -runDir $runDir -library $libName -topCell $cellName -view $viewName -logFile $logFile $sumCmd $mapCmd"
 
# 运行
exec $command