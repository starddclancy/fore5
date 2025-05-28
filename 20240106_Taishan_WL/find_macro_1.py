import os
import csv
import pwd

def load_strings_from_csv(csv_file):
    with open(csv_file, 'r') as f:
        reader = csv.reader(f)
        strings = [row[0] for row in list(reader)[1:]]
    print(f"Loaded strings from CSV: {strings}")
    return strings

def get_file_owner(file_path):
    return pwd.getpwuid(os.stat(file_path).st_uid).pw_name

def find_files_with_strings(path, strings, ignored_folders=[]):
    found_files = []

    for root, dirs, files in os.walk(path):
        # 忽略指定的文件夹
        dirs[:] = [d for d in dirs if d not in ignored_folders]

        for file in files:
            if file.endswith('.oas') or file.endswith('.oasis'):
                for string in strings:
                    if string in file:
                        file_path = os.path.join(root, file)
                        owner = get_file_owner(file_path)
                        found_files.append((file, owner, file_path))
                        print(f"Found file: {file} at {file_path} owned by: {owner}")
                        break

    return found_files

def write_to_csv(data, output_file):
    with open(output_file, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['File Name', 'Owner', 'File Path'])
        for row in data:
            writer.writerow(row)
    print(f"Results written to {output_file}")

if __name__ == "__main__":
    path = "/path/to/search"  # 替换为您要搜索的路径
    input_csv = "your_input.csv"  # 替换为您的输入CSV文件路径
    strings = load_strings_from_csv(input_csv)
    ignored_folders = ["IGNORED_FOLDER_1", "IGNORED_FOLDER_2"]  # 根据需要添加或删除忽略的文件夹

    print(f"Searching in {path} while ignoring folders: {ignored_folders}")
    found_files = find_files_with_strings(path, strings, ignored_folders)
    write_to_csv(found_files, 'output.csv')
