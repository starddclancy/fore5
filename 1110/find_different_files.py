import os
import pandas as pd

def normalize_filename(filename):
    """去掉特殊后缀或处理特殊命名规则"""
    if '_modify' in filename:
        return filename.replace('_modify', '')
    return filename

def list_files(directory):
    """递归列出目录下的所有文件并规范化文件名"""
    files_list = {}
    for root, dirs, files in os.walk(directory):
        for file in files:
            normalized_name = normalize_filename(file)
            files_list[normalized_name] = file
    return files_list

def compare_directories_to_csv(dir1, dir2, output_csv='directory_comparison.csv'):
    dir1_files = list_files(dir1)
    dir2_files = list_files(dir2)

    extra_in_dir1 = set(dir1_files.keys()) - set(dir2_files.keys())
    extra_in_dir2 = set(dir2_files.keys()) - set(dir1_files.keys())

    # 创建一个包含比较结果的DataFrame
    comparison_data = []
    for file in extra_in_dir1:
        comparison_data.append({'File': file, 'Present In': 'Dir1'})
    for file in extra_in_dir2:
        comparison_data.append({'File': file, 'Present In': 'Dir2'})

    comparison_df = pd.DataFrame(comparison_data)
    comparison_df.to_csv(output_csv, index=False)
    print(f"Comparison results saved to {output_csv}")

# 使用示例
dir1 = 'path_to_your_first_directory'  # 第一个目录的路径
dir2 = 'path_to_your_second_directory' # 第二个目录的路径

compare_directories_to_csv(dir1, dir2)
