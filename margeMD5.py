import os

def merge_md5sum_files(directory):
    merged_data = []
    
    # 遍历指定目录下的第一级文件夹
    for subdir in os.listdir(directory):
        subdir_path = os.path.join(directory, subdir)
        if os.path.isdir(subdir_path):
            md5sum_file_path = os.path.join(subdir_path, 'md5sum')
            if os.path.exists(md5sum_file_path):
                with open(md5sum_file_path, 'r') as file:
                    merged_data.extend(file.readlines())
    
    # 将合并的数据写入新的文件
    merged_file_path = os.path.join(directory, 'merged_md5sum.txt')
    with open(merged_file_path, 'w') as file:
        file.writelines(merged_data)

    return merged_file_path

# 您可以调用上面的函数，指定您的目录：
# merged_file = merge_md5sum_files('/path/to/your/directory')
# print(f"合并后的文件路径为: {merged_file}")
