import os
import csv
import pya

def find_oas_files(directory):
    """ 遍历文件夹，找到所有的.oas文件 """
    oas_files = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.oas'):
                oas_files.append(os.path.join(root, file))
    return oas_files

def get_topcell_name(oas_file):
    """ 从.oas文件中获取顶层单元名称 """
    layout = pya.Layout()
    layout.read(oas_file)
    topcell = layout.top_cell()
    return topcell.name if topcell else None

def write_to_csv(data, filename):
    """ 将数据写入CSV文件 """
    with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['Topcell Name', 'File Path'])
        for row in data:
            writer.writerow(row)

def main():
    directory = "path/to/your/directory"  # 替换为你的目标文件夹路径
    output_csv = "output.csv"             # 输出CSV文件的名称
    oas_files = find_oas_files(directory)

    data = []
    for file in oas_files:
        topcell_name = get_topcell_name(file)
        if topcell_name:
            data.append([topcell_name, file])

    write_to_csv(data, output_csv)

if __name__ == "__main__":
    main()
