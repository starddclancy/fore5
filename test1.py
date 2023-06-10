#######给定表格，导入对应的oas，导出表格中macro name $OUTLINE的长和宽###


import klayout.db as pydb
import pandas as pd
import tkinter as tk
from tkinter import filedialog, messagebox

def export_outline_dimensions(oas, excel, output_excel):
    # Read Excel
    df = pd.read_excel(excel)
    
    # Load layout
    main_layout = pydb.Layout()
    main_layout.read(oas)
    
    # Initialize lists to store width and length values
    widths = []
    lengths = []

    # Iterate through Excel rows
    for _, row in df.iterrows():
        cell_name = row[0]  # Assuming the column name is 'Cell Name'

        # Find the required cell
        cell = main_layout.cell(cell_name)
        if cell is not None:
            outline_layer = main_layout.layer(2014, 0)  # Assuming the $OUTLINE layer has the index (0, 0)
            width, length = get_outline_dimensions(cell, outline_layer)
            
            # Store the width and length values
            widths.append(width)
            lengths.append(length)
        else:
            widths.append(None)
            lengths.append(None)
    
    # Add width and length values to the DataFrame
    df['Width'] = widths
    df['Length'] = lengths

    # Export the DataFrame to a new Excel file
    df.to_excel(output_excel, index=False)

def get_outline_dimensions(cell, layer):
    # Calculate the bounding box of the cell for the specified layer
    bbox = cell.bbox_per_layer(layer)

    # Return the width and length of the bounding box
    return bbox.width(), bbox.height()

def main():
    root = tk.Tk()
    root.withdraw()

    oas_file = filedialog.askopenfilename(title="Select the OAS file", filetypes=[("OAS files", "*.oas")])
    excel_file = filedialog.askopenfilename(title="Select the Excel file", filetypes=[("Excel files", "*.xlsx;*.xls")])
    output_excel = filedialog.asksaveasfilename(title="Save the output Excel file", defaultextension=".xlsx", filetypes=[("Excel files", "*.xlsx;*.xls")])

    if oas_file and excel_file and output_excel:
        export_outline_dimensions(oas_file, excel_file, output_excel)
        messagebox.showinfo("Success", "Width and length values have been exported to the output Excel file.")
    else:
        messagebox.showerror("Error", "Please provide valid OAS file, Excel file, and output Excel file.")

if __name__ == "__main__":
    main()
