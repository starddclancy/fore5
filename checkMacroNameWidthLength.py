####导出OAS中第一层cell的$OUTlINE的长和宽

import klayout.db as pydb
import pandas as pd
import tkinter as tk
from tkinter import filedialog, messagebox
import glob
import os

def get_oas_files(dir):
    return glob.glob(dir + "/*.oas")

def extract_outline_info(oas_file):
    # Load layout
    main_layout = pydb.Layout()
    main_layout.read(oas_file)
    
    # Find the $OUTLINE layer
    outline_layer = None
    for layer_info in main_layout.layer_infos():
        print(layer_info)
        if layer_info.name == "$OUTLINE":
            outline_layer = main_layout.layer(layer_info)
            break

    if outline_layer is None:
        print(f"Warning: Could not find a layer with the name '$OUTLINE' in the file {oas_file}. Skipping this file.")
        return []

    # Initialize the data list
    data = []

    # Iterate through top-level cells (macros)
    for cell in main_layout.top_cells():
        
        # Get the width and length of the $OUTLINE layer
        width, length = get_width_length(cell, outline_layer)

        # Store the macro name, width, and length
        data.append([cell.name, width, length])

    return data




def get_width_length(cell, layer):
    # Calculate the bounding box of the cell for the specified layer
    bbox = cell.bbox_per_layer(layer)

    # Return the width and length of the bounding box
    return bbox.width(), bbox.height()

def main():
    root = tk.Tk()
    root.withdraw()

    oas_folder = filedialog.askdirectory(title="Select the OASIS directory")
    oas_files = get_oas_files(oas_folder)

    output_excel = filedialog.asksaveasfilename(title="Save the output Excel file", defaultextension=".xlsx", filetypes=[("Excel files", "*.xlsx;*.xls")])

    if oas_files and output_excel:
        all_data = []

        for oas_file in oas_files:
            oas_data = extract_outline_info(oas_file)
            all_data.extend(oas_data)

        # Create a DataFrame from the collected data
        df = pd.DataFrame(all_data, columns=['Macro Name', 'Width', 'Length'])

        # Export the DataFrame to an Excel file
        df.to_excel(output_excel, index=False)
        messagebox.showinfo("Success", "Width and length values have been exported to the output Excel file.")
    else:
        messagebox.showerror("Error", "Please provide a valid OASIS directory and output Excel file.")

if __name__ == "__main__":
    main()
