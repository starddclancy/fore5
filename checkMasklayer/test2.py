import pandas as pd  # 用于处理数据表格
import klayout.db as pydb  # 用于处理布局
import tkinter as tk  # 用于创建图形用户界面
from tkinter import filedialog  # 用于实现文件选择对话框
import os  # 用于处理文件和目录路径

# Function to get the coverage relationship of specified layer and macro
def find_macros_under_id_layer(input_oasis_file, macro_names, id_layers):
    # Load the original layout
    main_layout = pydb.Layout()
    main_layout.read(input_oasis_file)

    # Create a new layout for output
    output_layout = pydb.Layout()
    output_layout.dbu = main_layout.dbu

    # Process each identification layer
    for _, id_layer in id_layers.iterrows():
        id_layer_number, id_layer_datatype = map(int, id_layer['Layer Number/Datatype Number'].split("/"))
        id_layer_name = id_layer['Layer Name']

        if main_layout.find_layer(id_layer_number, id_layer_datatype) == -1:
            print(f"Layer {id_layer_name} ({id_layer_number}/{id_layer_datatype}) not found in the layout")
            continue

        id_layer_index = main_layout.find_layer(id_layer_number, id_layer_datatype)

        # Process each macro
        for _, macro in macro_names.iterrows():
            macro_name = macro['Macro Name']
            if not main_layout.has_cell(macro_name):
                print(f"Macro {macro_name} not found in the layout")
                continue

            macro_cell = main_layout.cell(macro_name)

            # Copy the macro cell to the output layout
            macro_cell_index_in_output = output_layout.copy_tree(macro_cell)

            # Merge the identification layer into the macro cell in the output layout
            for shape in macro_cell.shapes(id_layer_index).each():
                output_layout.cell(macro_cell_index_in_output).shapes(id_layer_index).insert(shape)

    # Save the output layout to a new .oas file
    output_layout.write("Marge_output.oas")

def run_export():
    root = tk.Tk()
    root.withdraw()  # Hide the main window
    input_oasis_file = filedialog.askopenfilename(filetypes=(("OASIS files", "*.oas"),))  # Pop up a dialog box to select the input .oas file
    macro_name_file = filedialog.askopenfilename(filetypes=(("Excel Files", "*.csv"),))  # Pop up a dialog box to select the Excel file containing macro names
    id_layer_file = filedialog.askopenfilename(filetypes=(("Excel Files", "*.csv"),))  # Pop up a dialog box to select the Excel file containing layer information

    # Load the Excel files
    macro_names_df = pd.read_csv(macro_name_file)
    id_layers_df = pd.read_csv(id_layer_file)

    # Run the main function
    find_macros_under_id_layer(input_oasis_file, macro_names_df, id_layers_df)

run_export()  # Run the main program
