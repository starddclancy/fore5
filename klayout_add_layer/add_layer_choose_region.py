
import os
import pya as db

# 载入现有的布局文件
input_file = "existing_layout.oas"  # 确保这个路径是正确的
layout = db.Layout()
layout.dbu = 0.001
'''
if layout.read(input_file):
    print(f"成功读取布局文件：{input_file}")
else:
    print(f"无法读取布局文件：{input_file}")
    exit(1)
'''
# 定义要添加的图层编号和数据类型
layer_number = 1
data_type = 0

# 创建或获取图层
layer_index = layout.layer(layer_number, data_type)

# 获取顶层单元
top_cell = layout.create_cell("TOP")
'''
if layout.has_cell(top_cell_name):
    top_cell_index = layout.cell_by_name(top_cell_name)
    top_cell = layout.cell(top_cell_index)
    print(f"找到顶层单元：{top_cell_name}")
else:
    print(f"单元 '{top_cell_name}' 不存在，将创建它。")
    top_cell = layout.create_cell(top_cell_name)
'''
# 定义要添加的矩形坐标
rectangles = [
    (1000, 2000, 5000, 6000),
    (7000, 8000, 12000, 15000),
    # 添加更多矩形坐标
]

# 遍历矩形列表，为每个矩形创建db.Box并添加到图层中
for rect in rectangles:
    x1_dbu, y1_dbu, x2_dbu, y2_dbu = [coord / layout.dbu for coord in rect]
    box = db.Box(x1_dbu, y1_dbu, x2_dbu, y2_dbu)
    top_cell.shapes(layer_index).insert(box)
    print(f"添加矩形：{rect}")

# 保存更改后的布局到一个新文件
output_file = r"D:\clancywang_18524819466\Code\klayout_add_layer\modified_layout.oas"  # 确保输出目录存在且有写权限
layout.write(output_file)
print(f"布局已保存到：{output_file}")
