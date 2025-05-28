import os
import pya
import sys
import time

class safesub(dict):
    def __missing__(self, key):
        return '{ + key + }'

def sub(text):
    return text.format_map(safesub(sys.getframe(1).f_locals))

xor_dir1 = "./dir1"
xor_dir2 = "./dir2"

def batch_xor(xor_dir1, xor_dir2):
    for root, dirs, files in os.walk(xor_dir1):
        for filename in files:
            if filename.endswith('.oasis') or filename.endswith('.oas'):
                file_path1 = os.path.join(root, filename)
                layout = pya.layout()
                layout.dbu = 0.001
                layout.read(file_path1)
                dir1_topcell_name = layout.top_cell().name
                for root, dirs, files in os.walk(xor_dir2):
                    if filename.endswith('.oasis') or filename.endswith('.oas'):
                        file_path2 = os.path.join(root, filename)
                        layout = pya.layout()
                        layout.dbu = 0.001
                        layout.read(file_path2)
                        dir2_topcell_name = layout.top_cell().name
                        if dir1_topcell_name == dir2_topcell_name:
                            os.system(f'mkdir xor_{time.strftime("%m%d%Y")}')
                            os.system(f'dbdiff -turbo -system {layout_system} -design {file_path1} -refdesign {file_path2} -write_xor_rules {dir1_topcell_name}.xor')
                            os.system(f'calibre -drc -turbo -fx -hier xor_{time.strftime("%m%d%Y")}/{dir1_topcell_name}.xor | {dir1_topcell_name}_xor.log')
                            continue






