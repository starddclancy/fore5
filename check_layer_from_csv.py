import csv
import os
import pya

def read_input_csv(csv_path):
    """Read the CSV file and return a list of layer definitions."""
    with open(csv_path, newline='') as csvfile:
        reader = csv.reader(csvfile)
        next(reader)  # Skip the header row
        return list(reader)

def write_output_csv(output_path, data):
    """Write data to a CSV file."""
    with open(output_path, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerows(data)

def layer_exists_in_layout(layout, layer_number, datatype):
    """Check if the given layer number and datatype combination exists in the layout."""
    existing_layers = {(linfo.layer, linfo.datatype) for linfo in layout.layer_infos()}
    return (layer_number, datatype) in existing_layers

def check_layers_in_layout(layout, layer_definitions):
    """Check if specified layers exist in the layout."""
    layer_presence = {}
    for layer_name, str_layer_number, str_datatype in layer_definitions:
        layer_number = int(str_layer_number)
        datatype = int(str_datatype)
        layer_presence[layer_name] = layer_exists_in_layout(layout, layer_number, datatype)
    return layer_presence

def generate_report(input_csv_path, layouts_dir, output_csv_path):
    """Generate the report."""
    layer_definitions = read_input_csv(input_csv_path)
    output_data = [['TopCell'] + [name for name, _, _ in layer_definitions]]
    
    for filename in os.listdir(layouts_dir):
        if filename.endswith(('.oas', '.oasis', '.remapped')):
            print(f"Processing: {filename}")
            layout = pya.Layout()
            layout.read(os.path.join(layouts_dir, filename))
            top_cell = layout.top_cell()
            if top_cell:
                layer_presence = check_layers_in_layout(layout, layer_definitions)
                row = [top_cell.name] + ['1' if layer_presence[name] else '0' for name, _, _ in layer_definitions]
                output_data.append(row)
    
    write_output_csv(output_csv_path, output_data)
    print("Report generated:", output_csv_path)

# Example usage
input_csv_path = 'path/to/your/input.csv'  # Path to the input CSV file
layouts_dir = 'path/to/your/layouts/dir'  # Directory containing layout files
output_csv_path = 'path/to/your/output.csv'  # Path to the output CSV file
generate_report(input_csv_path, layouts_dir, output_csv_path)

###is work根据csv文件中的layer信息来检查指定文件夹中的layout是否存在指定层   csv第一列为layername 第二列为layer_num 第三列为 datatype
