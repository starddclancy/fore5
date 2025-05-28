import os

def merge_txt_files(directory, output_file_name='merged.txt'):
    merged_data = []
    
    # 遍历指定目录下的所有文件
    for file_name in os.listdir(directory):
        file_path = os.path.join(directory, file_name)
        # 只处理.txt文件
        if os.path.isfile(file_path) and file_name.endswith('.txt'):
            with open(file_path, 'r') as file:
                merged_data.extend(file.readlines())
    
    # 将合并的数据写入新的文件
    output_file_path = os.path.join(directory, output_file_name)
    with open(output_file_path, 'w') as file:
        file.writelines(merged_data)

    return output_file_path

# 您可以调用上面的函数，指定您的目录和输出文件名（可选）：
# merged_file = merge_txt_files('/path/to/your/directory', 'output.txt')
# print(f"合并后的文件路径为: {merged_file}")
