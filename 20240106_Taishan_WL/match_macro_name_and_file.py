import pandas as pd
import os

# 1. 读取表格数据
input_filepath = "your_input_filepath.xlsx" # 替换为您的文件路径
df = pd.read_excel(input_filepath)
macro_names = df['Macro_Name'].tolist()

# 2. 遍历指定文件夹
folder_path = "your_folder_path" # 替换为您的文件夹路径
result = []

for root, dirs, files in os.walk(folder_path):
    for file in files:
        for macro_name in macro_names:
            if macro_name in file:
                result.append({"Macro_Name": macro_name, "File": file})

# 3. 保存结果到新表格
result_df = pd.DataFrame(result)

# 4. 标注Macro_Name对应多个文件的情况
result_df['Multiple_Files'] = result_df.groupby('Macro_Name')['File'].transform('size') > 1

# 保存结果
output_filepath = "your_output_filepath.xlsx" # 替换为您的输出文件路径
result_df.to_excel(output_filepath, index=False)
