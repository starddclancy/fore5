#直接提取第二层所有的子macro

import klayout.db as pydb
from datetime import datetime
import tkinter as tk
from tkinter import filedialog, messagebox
import glob

def get_all_oas_files(directory):
    return glob.glob(directory + "/*.oas")

def export_macros(input_oasis_file, output_directory):
    # 获取当前日期
    current_date = datetime.now().strftime("%Y-%m-%d")

    # 加载原始布局
    main_layout = pydb.Layout()
    main_layout.read(input_oasis_file)

    # 获取顶层 cell
    top_cell = main_layout.top_cell()

    # 遍历顶层 cell 的所有子 cell（第二层）
    for child_cell_index in top_cell.each_child_cell():
        child_cell = main_layout.cell(child_cell_index)
        macro_name = child_cell.name

        # 创建一个新的布局
        output_layout = pydb.Layout()
        output_layout.dbu = main_layout.dbu

        # 将当前宏复制到新布局中
        new_macro_cell = output_layout.create_cell(macro_name)
        new_macro_cell.copy_tree(child_cell)

        # 根据macro名称和当前日期生成导出的OASIS文件名
        output_oasis_file = f"{output_directory}/{macro_name}_clancy_{current_date}_RONALDO.oas"

        # 保存新的OASIS文件
        output_layout.write(output_oasis_file)
        print(f"Exported {macro_name} to {output_oasis_file}")

def browse_input_oasis_file():
    global input_oasis_directory
    input_oasis_directory = filedialog.askdirectory()
    input_oasis_label.config(text=input_oasis_directory)

def browse_output_directory():
    global output_directory
    output_directory = filedialog.askdirectory()
    output_directory_label.config(text=output_directory)

def run_export():
    if input_oasis_directory and output_directory:
        input_oasis_files = get_all_oas_files(input_oasis_directory)
        for input_oasis_file in input_oasis_files:
            export_macros(input_oasis_file, output_directory)
        messagebox.showinfo("Success", "Macros exported successfully!")
    else:
        messagebox.showwarning("Warning", "Please select input OASIS directory and output directory.")

# 创建图形界面窗口
root = tk.Tk()
root.title("Macro Exporter")

# 输入OASIS文件
input_oasis_label = tk.Label(root, text="Input OASIS file:")
input_oasis_label.grid(row=0, column=0, sticky="w")
input_oasis_button = tk.Button(root, text="Browse", command=browse_input_oasis_file)
input_oasis_button.grid(row=0, column=1)

# 输出目录
output_directory_label = tk.Label(root, text="Output directory:")
output_directory_label.grid(row=1, column=0, sticky="w")
output_directory_button = tk.Button(root, text="Browse", command=browse_output_directory)
output_directory_button.grid(row=1, column=1)

# 导出按钮
export_button = tk.Button(root, text="Export Macros", command=run_export)
export_button.grid(row=2, columnspan=2)

# 运行图形界面窗口
root.mainloop()
