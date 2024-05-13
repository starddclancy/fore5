
        
import pya
import csv

def main(gds_filename, output_csv):
    # Load the layout
    layout = pya.Layout()
    layout.read(gds_filename)

    # Select a top cell
    top_cells = layout.top_cells()
    if not top_cells:
        raise ValueError("No top cell found.")
    top_cell = top_cells[0]

    # Get the bounding box and center of the top cell
    top_box = top_cell.bbox()
    top_center_x = (top_box.left + top_box.right) / 2
    top_center_y = (top_box.top + top_box.bottom) / 2

    # Open a CSV file for writing
    with open(output_csv, mode='w', newline='') as file:
        writer = csv.writer(file)
        # Write the header of the CSV file
        writer.writerow(['Cell Name', 'Relative Center X', 'Relative Center Y'])

        # Function to process each cell recursively
        def process_cell(cell, dx, dy):
            # Iterate over each instance in the cell
            for inst in cell.each_inst():
                sub_cell = inst.cell
                sub_cell_box = sub_cell.bbox()
                
                # Center point of the sub-cell
                sub_center_x = (sub_cell_box.left + sub_cell_box.right) / 2
                sub_center_y = (sub_cell_box.top + sub_cell_box.bottom) / 2

                # Calculate the transformation in database units
                trans = inst.trans.to_dtype(layout.dbu)
                new_dx = dx + trans.disp.x
                new_dy = dy + trans.disp.y

                # Calculate the coordinates relative to the center of the top cell
                relative_center_x = sub_center_x + new_dx - top_center_x
                relative_center_y = sub_center_y + new_dy - top_center_y
                
                # Write to the CSV file
                writer.writerow([sub_cell.name, relative_center_x, relative_center_y])

                # Recursively process deeper sub-cells
                process_cell(sub_cell, new_dx, new_dy)

        process_cell(top_cell, 0, 0)

    print(f"Results have been written to {output_csv}")

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 3:
        print("Usage: python script.py <gds_file_path> <output_csv_path>")
    else:
        main(sys.argv[1], sys.argv[2])
