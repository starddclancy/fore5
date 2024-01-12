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
