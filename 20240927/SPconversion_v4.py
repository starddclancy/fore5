import re
import sys

def process_subckt_correct(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        inside_subckt = False
        current_line = ""
        prefix_to_append = ""
        processing_xi_section = False
        skip_next_plus_line = False

        for line in infile:
            line = line.rstrip()
            if line.startswith('.SUBCKT'):
                inside_subckt = True
                processing_xi_section = False
                outfile.write(line + '\n')
                continue

            if line.startswith('.ENDS'):
                inside_subckt = False
                if current_line:
                    outfile.write(current_line + '\n')
                    current_line = ""
                outfile.write(line + '\n')
                continue

            if inside_subckt:
                if line.startswith('M'):
                    outfile.write(line + '\n')
                    skip_next_plus_line = True
                    continue
                if skip_next_plus_line and line.startswith('+'):
                    outfile.write(line + '\n')
                    skip_next_plus_line = False
                    continue
                if line.startswith('XI_'):
                    processing_xi_section = True
                if processing_xi_section:
                    if line.startswith('XI_'):
                        if current_line:
                            outfile.write(current_line + '\n')
                            current_line = ""
                        match = re.match(r'([^$T]+)\$T', line)
                        if match:
                            xi_prefix = match.group(1).split()[0].strip()
                            prefix_to_append = match.group(1).split()[1].strip()
                        line = re.sub(r'\$T.*?\$PINS', '', line)
                        pin_values = re.findall(r'=(\S+)', line)
                        current_line = f"{xi_prefix} " + ' '.join(pin_values)

                    elif line.startswith('+'):
                        pin_values = re.findall(r'=(\S+)', line)
                        current_line = current_line + ' ' + ' '.join(pin_values)
                        current_line += f" {prefix_to_append}"
                        outfile.write(current_line + '\n')
                        current_line = ""
                    else:
                        outfile.write(line + '\n')
                else:
                    outfile.write(line + '\n')

        if current_line:
            current_line += f" {prefix_to_append}"
            outfile.write(current_line + '\n')

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python process_subckt.py <input_file> <output_file>")
        sys.exit(1)
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    process_subckt_correct(input_file, output_file)
