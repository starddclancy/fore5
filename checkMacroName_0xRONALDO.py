#################导出第二层中所有的macor name 和用0xRONALDO开头的下层所有macro name

import csv
import klayout.db
import tkinter as tk
from tkinter import filedialog

class Application(tk.Frame):
    def __init__(self, master=None):
        super().__init__(master)
        self.master = master
        self.master.title("KLayout Macro Name Exporter")
        self.pack()
        self.create_widgets()

    def create_widgets(self):
        self.select_file_button = tk.Button(self, text="Select OAS File", command=self.select_file)
        self.select_file_button.pack(padx=10, pady=10)

        self.export_button = tk.Button(self, text="Export Macro Names", command=self.export_names, state="disabled")
        self.export_button.pack(padx=10, pady=10)

    def select_file(self):
        filename = filedialog.askopenfilename(filetypes=[("OAS Files", "*.oas")])
        if filename:
            self.filename = filename
            self.export_button.config(state="normal")

    def export_names(self):
        # 打开 OAS 文件
        layout = klayout.db.Layout()
        layout.read(self.filename)

        def export_macro_names(cell):
            macro_names = []
            for child_cell_id in cell.each_child_cell():
                child_cell = layout.cell(child_cell_id)
                if child_cell.name.startswith("0xRONALDO"):
                    for grandchild_cell_id in child_cell.each_child_cell():
                        grandchild_cell = layout.cell(grandchild_cell_id)
                        macro_names.append(grandchild_cell.name)
                else:
                    macro_names.append(child_cell.name)
            return macro_names

        macro_names = []
        for cell_id in layout.each_top_cell():
            cell = layout.cell(cell_id)
            macro_names.extend(export_macro_names(cell))

        # 将名称写入 CSV 文件
        with open("macro_names.csv", "w", newline="") as f:
            writer = csv.writer(f)
            writer.writerow(["Macro Name"])
            for name in macro_names:
                writer.writerow([name])

        # 显示成功消息
        success_msg = f"Macro names exported to macro_names.csv"
        tk.messagebox.showinfo("Export Successful", success_msg)

# 创建 GUI
root = tk.Tk()
app = Application(master=root)
app.mainloop()
