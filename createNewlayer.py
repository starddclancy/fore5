import os
import pya

def process_oas_file(oas_file):
    """
    Process a single .oas file.
    For demonstration purposes, this function will print the file name.
    You can replace this with any other functionality you want.
    
    Parameters:
    - oas_file: str, path to the .oas file.
    """
    print(f"Processing {oas_file}")

    layout = pya.Layout()
    layout.read(oas_file)
    
    # Here, you can add your logic to process the layout, such as copying layers, etc.
    
    # Save the layout if necessary
    # layout.write(output_file)

def process_all_oas_files_in_directory(directory_path):
    """
    Process all .oas files in the given directory.
    
    Parameters:
    - directory_path: str, path to the directory.
    """
    for root, _, files in os.walk(directory_path):
        for file in files:
            if file.endswith(".oas"):
                full_path = os.path.join(root, file)
                process_oas_file(full_path)


directory_path = "path_to_your_directory"
process_all_oas_files_in_directory(directory_path)
