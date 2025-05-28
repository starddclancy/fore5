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
layout_system = "OASIS"


class cwTools:

    def batch_xor(xor_dir1, xor_dir2):
        option = pya.LoadLayoutOptions()
        option.format = "OASIS"
        for root, dirs, files in os.walk(xor_dir1):
            for filename in files:
                if filename.endswith('.oasis') or filename.endswith('.oas'):
                    file_path1 = os.path.join(root, filename)
                    layout1 = pya.Layout()
                    layout1.dbu = 0.001
                    layout1.read(file_path1, option)
                    dir1_topcell_name = layout1.top_cell().name
                    for root, dirs, files in os.walk(xor_dir2):
                        if filename.endswith('.oasis') or filename.endswith('.oas'):
                            file_path2 = os.path.join(root, filename)
                            layout2 = pya.Layout()
                            layout2.dbu = 0.001
                            layout2.read(file_path2, option)
                            dir2_topcell_name = layout2.top_cell().name
                            if dir1_topcell_name == dir2_topcell_name:
                                os.system(f'mkdir xor_{time.strftime("%m%d%Y")}')
                                os.system(f'dbdiff -turbo -system {layout_system} -design {file_path1} -refdesign {file_path2} -write_xor_rules xor_{time.strftime("%m%d%Y")}/{dir1_topcell_name}.xor')
                                os.system(f'calibre -drc -turbo -fx -hier xor_{time.strftime("%m%d%Y")}/{dir1_topcell_name}.xor | xor_{time.strftime("%m%d%Y")}/{dir1_topcell_name}_xor.log')
                                continue






