import os
import pya

def copy_layer_in_oas_file(oas_file, original_layer, new_layer):
    """
    Copy contents of original_layer to new_layer in the given .oas file.
    
    Parameters:
    - oas_file: str, path to the .oas file.
    - original_layer: tuple, the original layer in the form (layer, datatype).
    - new_layer: tuple, the new layer in the form (layer, datatype).
    """
    layout = pya.Layout()
    layout.read(oas_file)

    original_layer_index = layout.find_layer(*original_layer)
    if original_layer_index == -1:
        print(f"Layer {original_layer} not found in {oas_file}. Skipping...")
        return

    new_layer_index = layout.layer(*new_layer)

    for cell in layout.each_cell():
        for shape in cell.shapes(original_layer_index).each():
            cell.shapes(new_layer_index).insert(shape.polygon)

    # Overwrite the original file or save to a new file, based on your preference
    layout.write(oas_file)

def process_all_oas_files_in_directory(directory_path, original_layer, new_layer):
    """
    Process all .oas files in the given directory by copying the contents of original_layer to new_layer.
    
    Parameters:
    - directory_path: str, path to the directory.
    - original_layer: tuple, the original layer in the form (layer, datatype).
    - new_layer: tuple, the new layer in the form (layer, datatype).
    """
    for root, _, files in os.walk(directory_path):
        for file in files:
            if file.endswith(".oas"):
                full_path = os.path.join(root, file)
                copy_layer_in_oas_file(full_path, original_layer, new_layer)

# 使用函数
directory_path = "path_to_your_directory"
original_layer_spec = (10, 0)  # 示例原始层
new_layer_spec = (11, 0)  # 示例新层
process_all_oas_files_in_directory(directory_path, original_layer_spec, new_layer_spec)
