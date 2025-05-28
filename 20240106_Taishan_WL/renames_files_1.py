import os
import csv

def rename_files(csv_path, directory_path):
    # 读取CSV文件，建立一个文件名映射
    name_map = {}
    with open(csv_path, 'r') as file:
        reader = csv.reader(file)
        for row in reader:
            if len(row) >= 2:  # 确保每一行至少有两列
                name_map[row[0]] = row[1]

    print(f"Loaded {len(name_map)} mappings from CSV.")

    files_in_directory = [f for f in os.listdir(directory_path) if f.endswith('.oas')]
    print(f"Found {len(files_in_directory)} .oas files in directory.")

    matched_files = 0
    # 遍历目录下的所有 .oas 文件
    for filename in files_in_directory:
        if filename in name_map:
            matched_files += 1
            # 获取新的文件名和旧的文件路径
            new_name = name_map[filename]
            old_path = os.path.join(directory_path, filename)
            new_path = os.path.join(directory_path, new_name)
            
            # 重命名文件
            os.rename(old_path, new_path)
            print(f"Renamed {filename} to {new_name}")

    print(f"Renamed {matched_files} files based on CSV mappings.")

# 使用方法
# rename_files("path_to_your_csv.csv", "path_to_your_directory")
import os
import csv

def rename_files(csv_path, directory_path):
    # 读取CSV文件，建立一个文件名前缀映射
    prefix_map = {}
    with open(csv_path, 'r') as file:
        reader = csv.reader(file)
        for row in reader:
            if len(row) >= 2:  # 确保每一行至少有两列
                prefix_map[row[0]] = row[1]

    print(f"Loaded {len(prefix_map)} mappings from CSV.")

    files_in_directory = os.listdir(directory_path)
    print(f"Found {len(files_in_directory)} files in directory.")

    matched_files = 0
    # 遍历目录下的所有文件
    for filename in files_in_directory:
        # 检查每个前缀
        for prefix, new_name in prefix_map.items():
            if filename.startswith(prefix):
                matched_files += 1
                # 生成新的文件名
                new_filename = filename.replace(prefix, new_name)
                old_path = os.path.join(directory_path, filename)
                new_path = os.path.join(directory_path, new_filename)
                
                # 重命名文件
                os.rename(old_path, new_path)
                print(f"Renamed {filename} to {new_filename}")
                break  # 一旦找到匹配的前缀，就不再检查其他前缀

    print(f"Renamed {matched_files} files based on CSV mappings.")

# 使用方法
# rename_files("path_to_your_csv.csv", "path_to_your_directory")
