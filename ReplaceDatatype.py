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