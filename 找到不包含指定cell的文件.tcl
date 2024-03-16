# 指定版图文件所在的目录
set directory "path/to/your/directory"
# 指定cell列表
set cellsToCheck [list "cell1" "cell2" "cell3"]
# 指定输出CSV文件的路径
set outputPath "missing_cells_files.csv"

# 打开输出文件以便写入
set fileId [open $outputPath "w"]
puts $fileId "FileName"

# 定义一个递归函数来处理目录和子目录
proc processDirectory {dir} {
    global cellsToCheck fileId
    set totalCells [llength $cellsToCheck]

    foreach item [glob -nocomplain -directory $dir *] {
        if {[file isdirectory $item]} {
            processDirectory $item
        } else {
            if {[string match "*.gds" $item] || [string match "*.oas" $item]} {
                set missingCellsCount 0

                # 执行layout peek命令一次，获取所有cell
                set P [layout peek $item -handle cache]
                set output [$P peek -cells]

                foreach cell $cellsToCheck {
                    if {[lsearch -exact $output $cell] == -1} {
                        incr missingCellsCount
                    }
                }

                # 仅当所有指定的cell都不在文件中时，记录该文件
                if {$missingCellsCount == $totalCells} {
                    puts $fileId $item
                }
            }
        }
    }
}

# 开始处理目录
processDirectory $directory

# 关闭文件
close $fileId

# 输出完成信息
puts "Process completed. Files without any of the specified cells have been listed in $outputPath"
