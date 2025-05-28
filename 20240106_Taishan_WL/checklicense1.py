import re
import pandas as pd

def add_or_append_v2(df, name, date, number):
    # Check if name already exists in dataframe
    if name in df['name'].values:
        # Get the existing row index
        idx = df[df['name'] == name].index[0]
        
        # Find the next available column for date and number
        col_suffix = 1
        while f"date_{col_suffix}" in df.columns and pd.notna(df.at[idx, f"date_{col_suffix}"]):
            col_suffix += 1
        
        # Add new columns if necessary
        if f"date_{col_suffix}" not in df.columns:
            df[f"date_{col_suffix}"] = None
            df[f"number_{col_suffix}"] = None

        # Append date and number to the existing row
        df.at[idx, f"date_{col_suffix}"] = date
        df.at[idx, f"number_{col_suffix}"] = number
    else:
        # Add a new row for the new name
        new_data = {"name": name, "date_1": date, "number_1": number}
        df = df._append(new_data, ignore_index=True)
    return df

# 指定你的文件路径
input_file_path = 'test.txt'
output_file_path = 'test_out_1.csv'

# 读取文件内容
with open(input_file_path, 'r') as file:
    text = file.read()

# 正则表达式，用于匹配所需的模式
pattern = r'(FEATURE|INCREMENT) (\w+) .*? (\d{1,2}-\w{3}-\d{4}) (\d+)'

# 使用正则表达式找到所有匹配项
matches = re.findall(pattern, text)

# Create an empty dataframe with initial columns
df = pd.DataFrame(columns=["name", "date_1", "number_1"])

# Populate the dataframe using the add_or_append_v2 function
for match in matches:
    df = add_or_append_v2(df, match[1], match[2], match[3])

# 将 DataFrame 保存为 CSV 文件，不保存索引
df.to_csv(output_file_path, index=False)
