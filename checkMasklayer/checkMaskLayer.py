import pandas as pd  # 用于处理数据表格
import klayout.db as pydb  # 用于处理布局
import tkinter as tk  # 用于创建图形用户界面
from tkinter import filedialog  # 用于实现文件选择对话框
import os  # 用于处理文件和目录路径

# 定义函数，用于获取指定层和指定宏的覆盖关系
def find_macros_under_id_layer(input_oasis_file, macro_names, id_layers):
    # 加载原始布局
    main_layout = pydb.Layout()
    main_layout.read(input_oasis_file)

    # 结果将以字典的形式存储，其中每个宏名是一个键，每个值是一个字典，该字典将识别层名映射到该宏是否在该层下的布尔值
    results = {macro_name: {layer_name: None for layer_name in id_layers['Layer Name']} for macro_name in macro_names['Macro Name']}

    for _, id_layer in id_layers.iterrows():
        id_layer_number, id_layer_datatype = map(int, id_layer['Layer Number/Datatype Number'].split("/"))
        id_layer_name = id_layer['Layer Name']

        # 查找识别层
        # 检查层是否存在
        if main_layout.find_layer(id_layer_number, id_layer_datatype) == -1:
            print(f"Layer {id_layer_name} ({id_layer_number}/{id_layer_datatype}) not found in the layout")
            continue

        id_layer_index = main_layout.find_layer(id_layer_number, id_layer_datatype)


        # 创建一个 Region 对象，表示识别层的所有形状
        id_layer_region = pydb.Region()
        for cell in main_layout.each_cell():
            id_layer_region.insert(cell.begin_shapes_rec(id_layer_index))

        for _, macro in macro_names.iterrows():
            macro_name = macro['Macro Name']
            # 查找当前宏
            if not main_layout.has_cell(macro_name):
                print(f"Macro {macro_name} not found in the layout")
                continue

            macro_cell = main_layout.cell(macro_name)

            # 创建一个 Region 对象，表示当前宏的所有形状
            for layer_index in range(main_layout.layers()):
                macro_region = pydb.Region(macro_cell.begin_shapes_rec(layer_index))

            # 检查两个 Region 是否有重叠
            if id_layer_region.interacting(macro_region).is_empty():
                results[macro_name][id_layer_name] = "None"
            else:
                    results[macro_name][id_layer_name] = id_layer_name

    for macro_name in results:
        for id_layer_name in results[macro_name]:
            if results[macro_name][id_layer_name] is None:
                results[macro_name][id_layer_name] = "None"

    return results

# 定义函数，用于运行主程序
def run_export():
    root = tk.Tk()
    root.withdraw()  # 隐藏主窗口
    input_oasis_file = filedialog.askopenfilename(filetypes=(("OASIS files", "*.oas"),))  # 弹出对话框，选择输入的.oas文件
    macro_name_file = filedialog.askopenfilename(filetypes=(("Excel Files", "*.csv"),))  # 弹出对话框，选择包含宏名的Excel文件
    id_layer_file = filedialog.askopenfilename(filetypes=(("Excel Files", "*.csv"),))  # 弹出对话框，选择包含层信息的Excel文件
    # 读取Excel文件
    macro_names_df = pd.read_csv(macro_name_file)
    id_layers_df = pd.read_csv(id_layer_file)
    # 调用函数，获取覆盖关系
    results = find_macros_under_id_layer(input_oasis_file, macro_names_df, id_layers_df)
    # 将结果转换为 DataFrame
    df = pd.DataFrame(results)
    #   转置 DataFrame
    df = df.transpose()
    # 保存结果为 CSV 文件
    df.to_csv("output.csv")

run_export()  # 运行主程序
