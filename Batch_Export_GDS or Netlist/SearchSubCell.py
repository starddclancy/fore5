import os
import klayout.db as db
import csv

search_path = '/path/to/oas/files'  # 指定OASIS文件的路径
result_file = 'topcells_results.csv'

# 遍历指定目录下的所有OASIS文件
def find_cells(search_path):
    results = {}
    for root, dirs, files in os.walk(search_path):
        for filename in files:
            if filename.endswith('.remapped'):
                file_path = os.path.join(root, filename)
                layout = db.Layout()
                layout.read(file_path)
                
                # 获取topcell名称
                topcell_name = layout.top_cell().name
                
                # 检查以Z_PADSET开头的cell
                for cell in layout.each_cell():
                    if cell.name.startswith('Z_PADSET'):
                        for inst in cell.each_inst():
                            subcell = layout.cell(inst.cell_index)
                            if not subcell.name.startswith('Z_'):
                                results[topcell_name] = file_path
                                break  # 找到第一个符合条件的子cell后就跳出循环
                
    return results

def write_results_to_csv(results, result_file):
    with open(result_file, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['Top Cell Name', 'File Path'])
        for topcell_name, file_path in results.items():
            writer.writerow([topcell_name, file_path])

# 运行查找和写入操作
results = find_cells(search_path)
write_results_to_csv(results, result_file)