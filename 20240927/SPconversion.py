import re
import sys

def process_subckt_correct(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        inside_subckt = False
        current_line = ""
        prefix_to_append = ""
        skip_next_plus_line = False

        for line in infile:
            line = line.rstrip()  # 去除每行右侧的空格

            # 处理非 .SUBCKT 块的内容
            if not inside_subckt and not line.startswith('.SUBCKT') and not line.startswith('.ENDS'):
                outfile.write(line + '\n')
                continue
            
            # 处理 .SUBCKT 行，标记进入 SUBCKT 块
            if line.startswith('.SUBCKT'):
                inside_subckt = True
                outfile.write(line + '\n')
                continue

            # 处理 .ENDS 行，标记退出 SUBCKT 块
            if line.startswith('.ENDS'):
                inside_subckt = False
                if current_line:
                    outfile.write(current_line + '\n')  # 写入最后一行
                    current_line = ""  # 清空之前处理的行，避免多余的重复输出
                outfile.write(line + '\n')
                continue

            # 如果是以 'M' 开头的行，不做任何处理，直接写入
            if inside_subckt and line.startswith('M'):
                outfile.write(line + '\n')
                skip_next_plus_line = True  # 标记下一行 '+' 行不处理
                continue

            # 如果上一行是 'M' 开头的行，直接写入 '+' 开头的行，不做处理
            if skip_next_plus_line and line.startswith('+'):
                outfile.write(line + '\n')
                skip_next_plus_line = False  # 恢复正常处理
                continue

            if inside_subckt:
                if line.startswith('XI_'):  # 如果当前行以 XI_ 开头
                    if current_line:
                        outfile.write(current_line + '\n')
                        current_line = ""  # 清空之前处理的行

                    match = re.match(r'([^$T]+)\$T', line)
                    if match:
                        # 提取 XI_ 开头的前缀 (例如 XI_3856598E597)
                        xi_prefix = match.group(1).split()[0].strip()
                        # 保存 $T 前的最后部分作为续行的前缀 (例如 cad_dr_a_ary_tm)
                        prefix_to_append = match.group(1).split()[1].strip()
                    
                    # 移除 $T 到 $PINS 之间的内容
                    line = re.sub(r'\$T.*?\$PINS', '', line)
                    
                    # 只保留等号后面的值
                    pin_values = re.findall(r'=(\S+)', line)
                    current_line = f"{xi_prefix} " + ' '.join(pin_values)

                elif line.startswith('+'):  # 处理续行
                    pin_values = re.findall(r'=(\S+)', line)
                    current_line = current_line + ' ' + ' '.join(pin_values) + ' ' + prefix_to_append

                else:
                    outfile.write(line + '\n')  # 非 XI_ 行直接写入

        if current_line:
            outfile.write(current_line + '\n')


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python process_subckt.py <input_file> <output_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    process_subckt_correct(input_file, output_file)
