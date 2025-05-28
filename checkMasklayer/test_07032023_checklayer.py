import pandas as pd  # 用于处理数据表格
import klayout.db as pydb  # 用于处理布局
import tkinter as tk  # 用于创建图形用户界面
from tkinter import filedialog  # 用于实现文件选择对话框
import os  # 用于处理文件和目录路径

def copy_cell(source_layout, source_cell_index, target_layout, target_cell_index):
    source_cell = source_layout.cell(source_cell_index)
    target_cell = target_layout.cell(target_cell_index)

    for child_cell_index in source_cell.each_child_cell():
        if not target_layout.has_cell(source_layout.cell_name(child_cell_index)):  # 检查目标布局中是否已存在该单元格
            # 如果目标布局中不存在该单元格，则在目标布局中创建一个新的单元格，并将源单元格的内容复制到新单元格中
            new_cell_index = target_layout.add_cell(source_layout.cell_name(child_cell_index))
            copy_cell(source_layout, child_cell_index, target_layout, new_cell_index)

    for layer_index in range(source_layout.layers()):
        layer_info = source_layout.get_info(layer_index)  # 获取源布局的层信息
        target_layer_index = target_layout.find_layer(layer_info)  # 在目标布局中查找对应的层
        if target_layer_index is None:  # 如果在目标布局中找不到对应的层，则在目标布局中创建一个新的层
            target_layer_index = target_layout.insert_layer(layer_info)

        # 将源单元格中的图形复制到目标单元格中
        for shape in source_cell.shapes(layer_index).each():
            target_cell.shapes(target_layer_index).insert(shape)


def find_macros_under_id_layer(input_oasis_file, macro_names, id_layers):
    # Load the original layout
    main_layout = pydb.Layout()
    main_layout.read(input_oasis_file)

    results = {macro_name: {layer_name: None for layer_name in id_layers['Layer Name']} for macro_name in macro_names['Macro Name']}

    for _, id_layer in id_layers.iterrows():
        id_layer_number, id_layer_datatype = map(int, id_layer['Layer Number/Datatype Number'].split("/"))
        id_layer_name = id_layer['Layer Name']

        if main_layout.find_layer(id_layer_number, id_layer_datatype) == -1:
            print(f"Layer {id_layer_name} ({id_layer_number}/{id_layer_datatype}) not found in the layout")
            continue

        id_layer_index = main_layout.find_layer(id_layer_number, id_layer_datatype)

        for _, macro in macro_names.iterrows():
            macro_name = macro['Macro Name']

            if not main_layout.has_cell(macro_name):
                print(f"Macro {macro_name} not found in the layout")
                continue

            macro_cell_index_in_main = main_layout.cell(macro_name).cell_index()

            output_layout = pydb.Layout()
            output_layout.dbu = main_layout.dbu

            macro_cell_index_in_output = output_layout.add_cell(macro_name)
            copy_cell(main_layout, macro_cell_index_in_main, output_layout, macro_cell_index_in_output)

            for shape in main_layout.cell(macro_cell_index_in_main).begin_shapes_rec(id_layer_index):
                if results[macro_name][id_layer_name] is None:
                    results[macro_name][id_layer_name] = id_layer_name
                else:
                    results[macro_name][id_layer_name] += f", {id_layer_name}"

            if not os.path.isdir('output'):
                os.mkdir('output')

            output_layout.write(os.path.join('output', f"{macro_name}.oas"))

    for macro_name in results:
        for id_layer_name in results[macro_name]:
            if results[macro_name][id_layer_name] is None:
                results[macro_name][id_layer_name] = "None"

    return pd.DataFrame(results).transpose()

def run_export():
    root = tk.Tk()
    root.withdraw()  # Hide the main window
    input_oasis_file = filedialog.askopenfilename(filetypes=(("OASIS files", "*.oas"),))  # Pop up a dialog box to select the input .oas file
    macro_name_file = filedialog.askopenfilename(filetypes=(("Excel Files", "*.csv"),))  # Pop up a dialog box to select the Excel file containing macro names
    id_layer_file = filedialog.askopenfilename(filetypes=(("Excel Files", "*.csv"),))  # Pop up a dialog box to select the Excel file containing layer information

    macro_names_df = pd.read_csv(macro_name_file)
    id_layers_df = pd.read_csv(id_layer_file)

    results_df = find_macros_under_id_layer(input_oasis_file, macro_names_df, id_layers_df)

    results_file_path = os.path.join(os.path.dirname(input_oasis_file), "results.csv")  # Output the results to the same directory as the input file
    results_df.to_csv(results_file_path)

    print(f"Finished! The results have been saved to {results_file_path}")

if __name__ == "__main__":
    run_export()