import os
import klayout.db as kdb
import csv

# 定义搜索路径和结果文件
search_path = 'path/to/oas/files'  # 指定OASIS文件的路径
result_file = 'topcells_with_mesh.csv'

# 遍历指定目录下的所有OASIS文件
def find_cells_with_mesh(search_path):
    results = []
    for filename in os.listdir(search_path):
        if filename.endswith('.oas'):
            file_path = os.path.join(search_path, filename)
            layout = kdb.Layout()
            layout.read(file_path)
            for cell in layout.each_cell():
                if cell.name.startswith('Z_PADSET'):
                    for inst in cell.each_inst():
                        subcell = layout.cell(inst.cell_index)
                        if subcell.name.startswith('mesh'):
                            results.append(layout.top_cell().name)
                            break  # 找到符合条件的子cell后就跳出循环
    return results

def write_results_to_csv(results, result_file):
    with open(result_file, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['Top Cell Name'])
        for result in results:
            writer.writerow([result])

# 运行查找和写入操作
results = find_cells_with_mesh(search_path)
write_results_to_csv(results, result_file)
