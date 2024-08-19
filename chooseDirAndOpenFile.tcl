package require Tk

# 创建主窗口
wm title . "选择文件或文件夹"

# 选择文件或文件夹的选项
set selection_type "folder"

# 选择文件或文件夹的函数
proc choose {} {
    global selection_type
    if {$selection_type == "folder"} {
        set path [tk_chooseDirectory]
    } else {
        set path [tk_getOpenFile]
    }

    if {$path ne ""} {
        .label configure -text "选择的路径: $path"
    } else {
        .label configure -text "未选择任何路径"
    }
}

# 创建选择类型的下拉菜单
label .label1 -text "请选择:"
pack .label1 -padx 10 -pady 5

optionMenu .option selection_type "folder" "file"
pack .option -padx 10 -pady 5

# 创建选择按钮
button .btn -text "选择路径" -command choose
pack .btn -padx 10 -pady 10

# 显示选择结果的标签
label .label -text "未选择任何路径"
pack .label -padx 10 -pady 10

# 进入主事件循环
tk_mainLoop