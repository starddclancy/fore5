import pandas as pd

# 加载CSV文件的路径
file1 = 'path_to_first_csv.csv'
file2 = 'path_to_second_csv.csv'

# 读取CSV文件的第一列
df1 = pd.read_csv(file1, usecols=[0])
df2 = pd.read_csv(file2, usecols=[0])

# 找出第一个文件独有的行
unique_to_file1 = df1[~df1.iloc[:,0].isin(df2.iloc[:,0])]

# 找出第二个文件独有的行
unique_to_file2 = df2[~df2.iloc[:,0].isin(df1.iloc[:,0])]

# 打印结果
print("第一个文件独有的行:")
print(unique_to_file1)
print("\n第二个文件独有的行:")
print(unique_to_file2)


import pandas as pd

# 加载CSV文件的路径
file1 = 'path_to_first_csv.csv'
file2 = 'path_to_second_csv.csv'

# 读取CSV文件
df1 = pd.read_csv(file1)
df2 = pd.read_csv(file2)

# 准备结果容器
matches_in_file2 = []
matches_in_file1 = []

# 检查第一个文件中的每行是否在第二个文件中
for index, row in df1.iterrows():
    if any((df2 == row).all(1)):
        matches_in_file2.append(True)
    else:
        matches_in_file2.append(False)

# 检查第二个文件中的每行是否在第一个文件中
for index, row in df2.iterrows():
    if any((df1 == row).all(1)):
        matches_in_file1.append(True)
    else:
        matches_in_file1.append(False)

# 添加结果到数据框中
df1['Match_in_file2'] = matches_in_file2
df2['Match_in_file1'] = matches_in_file1

# 写入结果到新的CSV文件
df1.to_csv('comparison_results_file1.csv', index=False)
df2.to_csv('comparison_results_file2.csv', index=False)


print("比较结果已保存到 'comparison_results_file1.csv' 和 'comparison_results_file2.csv'")


import pandas as pd

# 加载CSV文件的路径
file1 = 'path_to_first_csv.csv'
file2 = 'path_to_second_csv.csv'

# 读取CSV文件的第一列
df1 = pd.read_csv(file1, usecols=[0])
df2 = pd.read_csv(file2, usecols=[0])

# 获取第一列的列名
col_name1 = df1.columns[0]
col_name2 = df2.columns[0]

# 准备结果容器
matches_in_file2 = []
matches_in_file1 = []

# 检查第一个文件中的每个值是否在第二个文件中
for value in df1[col_name1]:
    matches_in_file2.append(value in df2[col_name2].values)

# 检查第二个文件中的每个值是否在第一个文件中
for value in df2[col_name2]:
    matches_in_file1.append(value in df1[col_name1].values)

# 添加结果到数据框中
df1['Match_in_file2'] = matches_in_file2
df2['Match_in_file1'] = matches_in_file1

# 写入结果到新的CSV文件
df1.to_csv('comparison_results_file1.csv', index=False)
df2.to_csv('comparison_results_file2.csv', index=False)

print("比较结果已保存到 'comparison_results_file1.csv' 和 'comparison_results_file2.csv'")
