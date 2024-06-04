import pandas as pd
import re

# 将文本数据转换为DataFrame
def convert_text_to_dataframe(file_path):
    with open(file_path, 'r') as file:
        data = file.read()
    
    lines = re.split(r'\s*\n\s*', data.strip())
    hotspots = []

    for i in range(0, len(lines), 3):
        name = re.split(r'\s+', lines[i])[1].strip('"')
        x = float(re.split(r'\s+', lines[i+1])[1].strip('"'))
        y = float(re.split(r'\s+', lines[i+2])[1].strip('"'))
        hotspots.append([name, x, y])

    df = pd.DataFrame(hotspots, columns=["Hotspot Name", "Hotspot X", "Hotspot Y"])
    return df

# 处理和排序数据的函数
def process_and_sort_data(df, sort_by, ll):
    if sort_by == 'Hotspot X':
        grouped_df = df.groupby('Hotspot Y')
    else:
        grouped_df = df.groupby('Hotspot X')

    sorted_df = pd.DataFrame()
    for name, group in grouped_df:
        group = group.sort_values(by=sort_by).reset_index(drop=True)
        for i in range(1, len(group)):
            x2 = group.loc[i, sort_by]
            x1 = group.loc[i-1, sort_by]
            group.loc[i-1, sort_by] = (x2 - x1 - ll) / 2 + x1
        sorted_df = pd.concat([sorted_df, group])

    return sorted_df.reset_index(drop=True)

# 将DataFrame转换为原始格式的文本
def dataframe_to_original_format(df):
    result = []
    for index, row in df.iterrows():
        result.append(f'Hotspot_Name "{row["Hotspot Name"]}"')
        result.append(f'Hotspot_X "{row["Hotspot X"]}"')
        result.append(f'Hotspot_Y "{row["Hotspot Y"]}"')
    return "\n".join(result)

# 读取文件路径和参数
file_path = 'hotspots.txt'  # 替换为你的文本文件路径
sort_by = 'Hotspot X'  # 排序列可以是 'Hotspot X' 或 'Hotspot Y'
ll = 1  # 固定值

# 转换文本为DataFrame
df = convert_text_to_dataframe(file_path)

# 处理和排序数据
sorted_df = process_and_sort_data(df, sort_by, ll)

# 将DataFrame转换为原始格式的文本
output_text = dataframe_to_original_format(sorted_df)

# 保存处理后的结果为文本文件
output_file_path = 'processed_hotspots.txt'
with open(output_file_path, 'w') as output_file:
    output_file.write(output_text)

# 打印输出文本
print(output_text)
print(f"Processed data saved to {output_file_path}")
