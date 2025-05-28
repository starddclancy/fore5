#找到指定路径下重复的文件和其所有者

import os
import csv
from collections import defaultdict

def load_folder_and_owner_from_csv(csv_file):
    folder_to_owners = defaultdict(list)
    with open(csv_file, 'r') as f:
        reader = csv.reader(f)
        for row in list(reader)[1:]:
            owner, file_path = row[1], row[2]
            folder_path = os.path.dirname(file_path)
            folder_to_owners[folder_path].append(owner)
    return folder_to_owners

def find_duplicate_folders(folder_to_owners):
    duplicates = {}
    for folder, owners in folder_to_owners.items():
        if len(owners) > 1:
            duplicates[folder] = set(owners)
    return duplicates

def write_to_csv(data, output_file):
    with open(output_file, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['Duplicate Folder', 'Owners'])
        for folder, owners in data.items():
            writer.writerow([folder, ', '.join(owners)])
    print(f"Results written to {output_file}")

if __name__ == "__main__":
    input_csv = "your_input.csv"  # 替换为您的输入CSV文件路径
    output_csv = "duplicates_output.csv"  # 输出的CSV文件路径

    print("Loading data from CSV...")
    folder_to_owners = load_folder_and_owner_from_csv(input_csv)

    print("Finding duplicate folders...")
    duplicate_folders = find_duplicate_folders(folder_to_owners)

    print("Writing results to CSV...")
    write_to_csv(duplicate_folders, output_csv)
