import os
import hashlib
import concurrent.futures
import csv

def calculate_md5(file_path):
    hash_md5 = hashlib.md5()
    with open(file_path, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

def check_single_file(args):
    checksum_dict, target_directory, root, file_name = args
    relative_path = os.path.relpath(root, target_directory)
    full_file_path = os.path.join(root, file_name)
    key_name = os.path.join(relative_path, file_name) if relative_path != '.' else file_name

    if key_name in checksum_dict:
        calculated_checksum = calculate_md5(full_file_path)
        if calculated_checksum != checksum_dict[key_name]:
            return ('Mismatch', key_name)
        del checksum_dict[key_name]
        return ('Match', key_name)
    return ('Unknown', key_name)

def check_files(checksum_file_path, target_directory, ignore_folders):
    checksum_dict = {}
    results = []

    tasks = []

    with open(checksum_file_path, 'r') as f:
        lines = f.readlines()
        for line in lines:
            checksum, file_name = line.strip().split()
            checksum_dict[file_name] = checksum

    for root, dirs, files in os.walk(target_directory):
        dirs[:] = [d for d in dirs if d not in ignore_folders]

        for file_name in files:
            tasks.append((checksum_dict, target_directory, root, file_name))

    with concurrent.futures.ThreadPoolExecutor() as executor:
        for status, key_name in executor.map(check_single_file, tasks):
            results.append([key_name, status])

    missing_files = list(checksum_dict.keys())
    for missing in missing_files:
        results.append([missing, "Missing"])

    # 输出到CSV文件
    with open('results.csv', 'w', newline='') as csvfile:
        csvwriter = csv.writer(csvfile)
        csvwriter.writerow(['File Name', 'Status'])  # 写入表头
        for result in results:
            csvwriter.writerow(result)  # 写入数据

if __name__ == "__main__":
    checksum_file_path = "checksums.txt"
    target_directory = "/path/to/target/files"
    ignore_folders = ["ignore_this_folder", "and_this_one"]

    check_files(checksum_file_path, target_directory, ignore_folders)
