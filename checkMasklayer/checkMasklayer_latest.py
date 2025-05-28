import pandas as pd  # 用于处理数据表格
import klayout.db as pydb  # 用于处理布局
import tkinter as tk  # 用于创建图形用户界面
from tkinter import filedialog  # 用于实现文件选择对话框
import os  # 用于处理文件和目录路径

def copy_cell(source_layout, source_cell_index, target_layout, target_cell_index):
    """
    Copy the shapes of source_cell in source_layout to target_cell in target_layout.
    最初
    """
    for layer_index in range(source_layout.layers()):
        source_shapes = source_layout.cell(source_cell_index).shapes(layer_index)

        if not source_shapes.is_empty():
            # If the layer does not exist in the target layout, create it
            if not target_layout.is_valid_layer(layer_index):
                layer_info = source_layout.get_info(layer_index)
                target_layout.insert_layer(layer_info)

            target_shapes = target_layout.cell(target_cell_index).shapes(layer_index)

            for shape in source_shapes.each():
                target_shapes.insert(shape)
                

'''def copy_cell(source_layout, source_cell_index, target_layout, target_cell_index):
    """
    Copy the shapes of source_cell in source_layout to target_cell in target_layout.
    """
    print(f"Copying Start.")

    for layer_index in range(source_layout.layers()):
        source_shapes = source_layout.cell(source_cell_index).shapes(layer_index)

        if not source_shapes.is_empty():
            # If the layer does not exist in the target layout, create it
            if target_layout.find_layer(source_layout.get_info(layer_index)) == -1:
                layer_info = source_layout.get_info(layer_index)
                target_layout.insert_layer(layer_info)
                print(f"Inserting new layer with index {layer_index} into target layout.")

            target_shapes = target_layout.cell(target_cell_index).shapes(layer_index)

            for shape in source_shapes.each():
                target_shapes.insert(shape)
                print(f"Copying shape from source layout to target layout.")
                最后一次
                '''





'''def find_macros_under_id_layer(input_oasis_file, macro_names, id_layers):
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

            # Create a deep copy of the source layout before modifying it
            source_layout_copy = pydb.Layout()
            source_layout_copy.assign(main_layout)

            copy_cell(source_layout_copy, macro_cell_index_in_main, output_layout, macro_cell_index_in_output)

            # Rest of the code...'''




def find_macros_under_id_layer(input_oasis_file, macro_names, id_layers):

    # Load the original layout最初修改
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


'''def find_macros_under_id_layer(input_oasis_file, macro_names, id_layers):
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

            # Merge macro and id layer
            output_layout.cell(macro_cell_index_in_output).shapes(id_layer_index).insert(main_layout.cell(macro_cell_index_in_main).shapes(id_layer_index))

            for shape in output_layout.cell(macro_cell_index_in_output).shapes(id_layer_index):
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
    第二次修改
    '''

def run_export():
    root = tk.Tk()
    root.withdraw()  # Hide the main window

    input_oasis_file = filedialog.askopenfilename(filetypes=(("OASIS files", "*.oas"),))  # Pop up a dialog box to select the input .oas file
    macro_names_file = filedialog.askopenfilename(filetypes=(("CSV files", "*.csv"),))  # Pop up a dialog box to select the macro names .csv file
    id_layers_file = filedialog.askopenfilename(filetypes=(("CSV files", "*.csv"),))  # Pop up a dialog box to select the id layers .csv file

    macro_names_df = pd.read_csv(macro_names_file)
    id_layers_df = pd.read_csv(id_layers_file)

    results_df = find_macros_under_id_layer(input_oasis_file, macro_names_df, id_layers_df)

    results_df.to_csv('results.csv')

if __name__ == "__main__":
    run_export()
