# 导入 KLayout 的相关模块
from pya import *

# 获取当前布局和主单元
layout = pya.Application.instance().main_window().current_view().active_cellview().layout()
top_cell = pya.Application.instance().main_window().current_view().active_cellview().cell
if not layout.has_top_cell():
    raise Exception("当前没有打开的布局或主单元")

# 获取所有的层信息
layers_to_modify = []

# 遍历布局中的所有图层
for layer_info in layout.layer_infos():
    if layer_info.datatype in [252, 251]:  # 检查 datatype 是否为 252 或 251
        layers_to_modify.append((layer_info.layer, layer_info.datatype))

# 替换为 datatype 0
for layer, datatype in layers_to_modify:
    old_layer_index = layout.find_layer(layer, datatype)
    new_layer_index = layout.layer(pya.LayerInfo(layer, 0))  # 创建新的图层，datatype 为 0
    for cell in layout.each_cell():
        cell.shapes(old_layer_index).move_to(new_layer_index)  # 移动图形到新图层
    layout.delete_layer(old_layer_index)  # 删除旧图层

# 刷新视图
pya.Application.instance().main_window().current_view().redraw()

print(f"已将所有 datatype 为 252 或 251 的图层替换为 datatype 0。")


from pya import *

# 输入和输出文件路径
input_file = "input.gds"  # 替换为你的输入 GDS 文件路径
output_file = "output.gds"  # 替换为你的输出 GDS 文件路径

# 加载布局
layout = Layout()
layout.read(input_file)

# 获取所有的层信息
layers_to_modify = []

# 遍历布局中的所有图层
for layer_info in layout.layer_infos():
    if layer_info.datatype in [252, 251]:  # 检查 datatype 是否为 252 或 251
        layers_to_modify.append((layer_info.layer, layer_info.datatype))

# 替换为 datatype 0
for layer, datatype in layers_to_modify:
    old_layer_index = layout.find_layer(layer, datatype)
    new_layer_index = layout.layer(LayerInfo(layer, 0))  # 创建新的图层，datatype 为 0
    for cell in layout.each_cell():
        cell.shapes(old_layer_index).move_to(new_layer_index)  # 移动图形到新图层
    layout.delete_layer(old_layer_index)  # 删除旧图层

# 保存修改后的布局
layout.write(output_file)

print(f"已将所有 datatype 为 252 或 251 的图层替换为 datatype 0，并保存到 {output_file}")

from pya import *

# 输入和输出文件路径
input_file = "input.gds"  # 替换为你的输入 GDS 文件路径
output_file = "output.gds"  # 替换为你的输出 GDS 文件路径

# 加载布局
layout = Layout()
layout.read(input_file)

# 获取所有的层信息
layers_to_modify = []

# 遍历布局中的所有图层
for layer_info in layout.layer_infos():
    if layer_info.datatype in [252, 251]:  # 检查 datatype 是否为 252 或 251
        layers_to_modify.append((layer_info.layer, layer_info.datatype))

# 替换为 datatype 0
for layer, datatype in layers_to_modify:
    old_layer_index = layout.find_layer(layer, datatype)
    new_layer_index = layout.layer(LayerInfo(layer, 0))  # 创建新的图层，datatype 为 0
    
    # 遍历所有 cell，将图形从旧图层移动到新图层
    for cell in layout.each_cell():
        shapes = cell.shapes(old_layer_index)
        new_shapes = cell.shapes(new_layer_index)
        
        # 复制旧图层的所有图形到新图层
        for shape in shapes.each():
            new_shapes.insert(shape)
        
        # 清空旧图层
        shapes.clear()

# 保存修改后的布局
layout.write(output_file)

print(f"已将所有 datatype 为 252 或 251 的图层替换为 datatype 0，并保存到 {output_file}")




