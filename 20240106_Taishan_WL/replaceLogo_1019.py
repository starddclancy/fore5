import os
import csv
import pandas as pd
import klayout.db as pya

def replace_cells(oas_folder, macro_cells_folder, macros_table_path, output_folder):
    # 使用pandas从Excel文件中读取数据
    df = pd.read_csv(macros_table_path)
    
    # 检查是否存在'Oasis_file_name'和'Macro_name'列
    if 'Oasis_file_name' not in df.columns or 'Macro_name' not in df.columns:
        print("Error: The CSV file does not have 'Oasis_file_name' or 'Macro_name' column.")
        return

    not_found_macros = []

    for index, row in df.iterrows():
        oas_file_name = row['Oasis_file_name']
        macro_name = row['Macro_name']

        oas_file_path = os.path.join(oas_folder, oas_file_name)
        if not os.path.exists(oas_file_path):
            print(f"OAS file {oas_file_name} not found!")
            continue

        print(f"Processing {oas_file_path}...")

        layout = pya.Layout()
        layout.read(oas_file_path)

        found_cell = None
        # 查找cell名称以"Z_STRING_GEN"或"STRING_GEN"开始的cell
        for cell_name_prefix in ["Z_STRING_GEN", "STRING_GEN"]:
            for cell in layout.each_cell():
                if cell.name.startswith(cell_name_prefix):
                    found_cell = cell
                    break
            if found_cell:
                break

        if found_cell:
            macro_cell_path = os.path.join(macro_cells_folder, f"{macro_name}.oas")
            if os.path.exists(macro_cell_path):
                macro_layout = pya.Layout()
                macro_layout.read(macro_cell_path)
                new_cell = macro_layout.top_cell()

                # 获取found_cell的边界并计算偏移
                bbox = found_cell.bbox()
                llx, lly = bbox.left, bbox.bottom

                # 清空found_cell内容
                found_cell.clear()

                # 删除found_cell的子cell
                for child_index in found_cell.each_child_cell():
                    if layout.is_valid_cell_index(child_index):
                        layout.prune_cell(child_index, True)

                # 将new_cell内容复制到found_cell
                found_cell.copy_tree(new_cell)

                # 计算偏移量
                new_bbox = found_cell.bbox()
                dx, dy = llx - new_bbox.left, lly - new_bbox.bottom

                # 创建偏移转换
                trans = pya.Trans(dx, dy)

                # 移动所有形状到新坐标
                for layer_index in layout.layer_indices():
                    shapes = found_cell.shapes(layer_index)
                    shapes.transform(trans)

                # 移动所有实例到新坐标
                for inst in found_cell.each_inst():
                    inst.transform(trans)

                # 保存修改后的布局到输出文件夹
                output_path = os.path.join(output_folder, f"{oas_file_name}_modify.oas")
                layout.write(output_path)
            else:
                print(f"Macro cell for {macro_name} not found in the folder!")
                if macro_name not in not_found_macros:
                    not_found_macros.append(macro_name)
        else:
            print(f"No cell starting with Z_STRING_GEN or STRING_GEN found in {oas_file_path}!")
            if macro_name not in not_found_macros:
                not_found_macros.append(macro_name)

    # 将未找到的宏名保存到CSV文件
    with open(os.path.join(output_folder, "not_found_macros.csv"), "w", newline='') as f:
        writer = csv.writer(f)
        writer.writerow(["Not_Found_Macros"])
        for macro in not_found_macros:
            writer.writerow([macro])

# 用户指定的路径
oas_folder_path = r"C:\Users\clancywang\Desktop\test"
macro_cells_folder_path = r"C:\Users\clancywang\Desktop\testlogo"
macros_table_path = r"C:\Users\clancywang\Desktop\Taishan_full_macro_name_list.csv"
output_folder_path = r"C:\Users\clancywang\Desktop\output"  # 输出文件夹路径

replace_cells(oas_folder_path, macro_cells_folder_path, macros_table_path, output_folder_path)
