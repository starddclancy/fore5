import pandas as pd
import os
import fnmatch

def find_files(directory, pattern):
    """遍历目录，找到匹配特定模式的所有文件"""
    matches = []
    for root, dirnames, filenames in os.walk(directory):
        for filename in fnmatch.filter(filenames, pattern):
            matches.append(os.path.join(root, filename))
    return matches

def process_csv_and_find_files(csv_path, directory, max_files_per_term=10):
    # 读取CSV文件
    df = pd.read_csv(csv_path)
    results = []

    # 对于CSV中的每一行，进行模糊匹配搜索
    for index, row in df.iterrows():
        search_term = f'*{row[0]}*'  # 假设你要匹配的字符串在每行的第一列
        matching_files = find_files(directory, search_term)

        # 如果找到多个匹配项，限制输出数量并添加到结果中
        if len(matching_files) > 1:
            limited_files = matching_files[:max_files_per_term]
            for file in limited_files:
                results.append([row[0], file])

    # 将结果写入新的CSV文件
    results_df = pd.DataFrame(results, columns=['Search Term', 'Matching File'])
    results_df.to_csv('matching_results.csv', index=False)

# 使用示例
csv_path = 'path_to_your_csv.csv'  # 你的CSV文件路径
directory = 'path_to_your_directory'  # 你要搜索的目录路径
process_csv_and_find_files(csv_path, directory)
