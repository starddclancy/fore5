def parse_and_format_separated(text, chip, proj, filepath):

    teg_related_lines = []
    teg_loc_lines = []

    for line in text.split('\n'):
        if line.strip():  # Ensure the line is not empty
            # Extracting $TEG and coordinates
            teg, coords = line.split('(', 1)
            teg = teg.strip().strip('"')
            coords = coords.strip(')').split(')(')
            llx, lly = map(float, coords[0].split())
            urx, ury = map(float, coords[1].split())

            # Calculating $W and $L
            w = int(urx) 
            l = int(ury)

            # Creating the formatted string for $TEG related lines
            formatted_teg = f"{teg}: {teg}_{proj} {chip} $K2_MC_DATA/{filepath} {teg} 0 0 {w} {l} 1 0:0 - 1 1\n"
            formatted_teg += f"ITEMFLAGS1 {teg} 0 OPT O 100\n"
            formatted_teg += f"ITEMFLAGS2 {teg} 0 0 -1 - 1 0\n"

            # Creating the formatted string for $TEG:LOC line
            formatted_teg_loc = f"{teg}:LOC {llx} {lly} 0 0 1 0 0"

            teg_related_lines.append(formatted_teg)
            teg_loc_lines.append(formatted_teg_loc)


    return '\n'.join(teg_related_lines), '\n'.join(teg_loc_lines)




# formatted_teg_output 和 formatted_teg_loc_output 将包含分开的两部分格式化文本。


def process_file_combined_output(input_file_path, output_file_path, chip, proj, filepath):
    with open(input_file_path, 'r') as file:
        text = file.read()

    formatted_teg_output, formatted_teg_loc_output = parse_and_format_separated(text, chip, proj, filepath)

    with open(output_file_path, 'w') as file:
        file.write(formatted_teg_output)
        file.write('\n'*10)  # 添加一个换行符以分隔两部分内容
        file.write(formatted_teg_loc_output)
        print("result output!!!")

# 输入文件路径（包含多行数据）
input_file_path = 'TEST.txt'

# 输出文件路径
output_file_path = 'path_to_your_combined_output_file.txt'

# 其他参数
chip = "CHIP_VALUE"
proj = "PROJ_VALUE"
filepath = "FILEPATH_VALUE"

# 调用函数处理文件
process_file_combined_output(input_file_path, output_file_path, chip, proj, filepath)


