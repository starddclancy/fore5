import pya
import csv

def main(gds_filename, output_csv):
    # 加载布局
    layout = pya.Layout()
    layout.read(gds_filename)

    # 选择一个顶层cell
    top_cells = layout.top_cells()
    if not top_cells:
        raise ValueError("No top cell found.")
    top_cell = top_cells[0]

    # 获取顶层cell的边界和中心点
    top_box = top_cell.bbox()
    top_center_x = (top_box.left + top_box.right) / 2
    top_center_y = (top_box.top + top_box.bottom) / 2

    # 打开CSV文件进行写入
    with open(output_csv, mode='w', newline='') as file:
        writer = csv.writer(file)
        # 写入CSV文件的表头
        writer.writerow(['Cell Name', 'Relative Center X', 'Relative Center Y'])

        # 遍历所有子cell，包括嵌套的子cell
        def process_cell(cell, dx, dy):
            # 遍历每个实例
            for inst in cell.each_inst():
                sub_cell = inst.cell
                sub_cell_box = sub_cell.bbox()
                
                # 子cell的中心点
                sub_center_x = (sub_cell_box.left + sub_cell_box.right) / 2
                sub_center_y = (sub_cell_box.top + sub_cell_box.bottom) / 2

                # 计算实例的位移（考虑到实例的变换）
                trans = inst.trans.to_dtype(layout.dbu)
                disp = trans.disp()
                new_dx = dx + disp.x
                new_dy = dy + disp.y

                # 计算相对于顶层cell的中心点坐标
                relative_center_x = sub_center_x + new_dx - top_center_x
                relative_center_y = sub_center_y + new_dy - top_center_y
                
                # 写入CSV文件
                writer.writerow([sub_cell.name, relative_center_x, relative_center_y])

                # 递归处理更深层的子cell
                process_cell(sub_cell, new_dx, new_dy)

        process_cell(top_cell, 0, 0)

    print(f"Results have been written to {output_csv}")

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 3:
        print("Usage: python script.py <gds_file_path> <output_csv_path>")
    else:
        main(sys.argv[1], sys.argv[2])