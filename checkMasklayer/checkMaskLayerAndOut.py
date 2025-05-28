import pandas as pd  # 用于处理数据表格
import klayout.db as pydb  # 用于处理布局
import tkinter as tk  # 用于创建图形用户界面
from tkinter import filedialog  # 用于实现文件选择对话框
import os  # 用于处理文件和目录路径

def find_macros_under_id_layer(input_oasis_file, macro_names, id_layers):
    # 加载原始布局
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

        id_layer_region = pydb.Region()
        for cell in main_layout.each_cell():
            id_layer_region.insert(cell.begin_shapes_rec(id_layer_index))

        for _, macro in macro_names.iterrows():
            macro_name = macro['Macro Name']

            if not main_layout.has_cell(macro_name):
                print(f"Macro {macro_name} not found in the layout")
                continue

            macro_cell = main_layout.cell(macro_name)

            for layer_index in range(main_layout.layers()):
                macro_region = pydb.Region(macro_cell.begin_shapes_rec(layer_index))

            # Create a new layout for the intersection
            intersection_layout = pydb.Layout()
            intersection_layout.dbu = main_layout.dbu
            intersection_layer_index = intersection_layout.insert_layer(pydb.LayerInfo(id_layer_number, id_layer_datatype))
            intersection_cell = intersection_layout.create_cell("Intersection")
            
            # Calculate the intersection of id_layer_region and macro_region
            intersection_region = id_layer_region.and_(macro_region)

            # If the intersection is not empty, insert the shapes into the intersection_cell
            if not intersection_region.is_empty():
                intersection_cell.shapes(intersection_layer_index).insert(intersection_region)
                
                # Save the intersection layout to a new .oas file
                intersection_layout.write(f"{macro_name}_intersection.oas")
            
            if not id_layer_region.and_(macro_region).is_empty():
                if results[macro_name][id_layer_name] is None:
                    results[macro_name][id_layer_name] = id_layer_name
                else:
                    results[macro_name][id_layer_name] += f", {id_layer_name}"

    for macro_name in results:
        for id_layer_name in results[macro_name]:
            if results[macro_name][id_layer_name] is None:
                results[macro_name][id_layer_name] = "None"

    return results


def run_export():
    root = tk.Tk()
    root.withdraw()  # Hide the main window
    input_oasis_file = filedialog.askopenfilename(filetypes=(("OASIS files", "*.oas"),))  # Pop up a dialog box to select the input .oas file
    macro_name_file = filedialog.askopenfilename(filetypes=(("Excel Files", "*.csv"),))  # Pop up a dialog box to select the Excel file containing macro names
    id_layer_file = filedialog.askopenfilename(filetypes=(("Excel Files", "*.csv"),))  # Pop up a dialog box to select the Excel file containing layer information

    macro_names_df = pd.read_csv(macro_name_file)
    id_layers_df = pd.read_csv(id_layer_file)
    results = find_macros_under_id_layer(input_oasis_file, macro_names_df, id_layers_df)

    df = pd.DataFrame(results)
    df = df.transpose()
    df.to_csv("output_andOutputOas.csv")

run_export()  # Run the main program
