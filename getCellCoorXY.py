import klayout.db as db
import pandas as pd
from tkinter import Tk, Label, Button, filedialog

class Application:
    def __init__(self, master):
        self.master = master
        self.layout_file = None
        self.input_csv_file = None
        self.output_csv_file = None

        self.label = Label(master, text="KLayout Cell Origin Exporter")
        self.label.pack()

        self.select_layout_button = Button(master, text="Select Layout File", command=self.select_layout)
        self.select_layout_button.pack()

        self.select_input_csv_button = Button(master, text="Select Input CSV File", command=self.select_input_csv)
        self.select_input_csv_button.pack()

        self.select_output_csv_button = Button(master, text="Select Output CSV File", command=self.select_output_csv)
        self.select_output_csv_button.pack()

        self.run_button = Button(master, text="Run", command=self.run)
        self.run_button.pack()

    def select_layout(self):
        self.layout_file = filedialog.askopenfilename(filetypes=[("OASIS files", "*.oas"), ("All files", "*.*")])

    def select_input_csv(self):
        self.input_csv_file = filedialog.askopenfilename(defaultextension=".csv")

    def select_output_csv(self):
        self.output_csv_file = filedialog.asksaveasfilename(defaultextension=".csv")

    def run(self):
        if self.layout_file and self.input_csv_file and self.output_csv_file:
            self.export_cell_origins(self.layout_file, self.input_csv_file, self.output_csv_file)
        else:
            print("Please select all files first.")

    def export_cell_origins(self, layout_file, input_csv_file, output_csv_file):
        # 初始化数据库并加载版图
        layout = db.Layout()
        layout.read(layout_file)

        # 从输入CSV文件中读取macro names
        input_df = pd.read_csv(input_csv_file)
        macro_names = set(input_df["Macro Name"])

        # 创建一个空的DataFrame来存储结果
        df = pd.DataFrame(columns=["Macro Name", "Position of Cell Origin"])

        # 遍历版图中的所有cell
        for cell in layout.each_cell():
            # 遍历该cell的所有实例
            for inst in cell.each_inst():
                # 如果该实例的cell名字在我们的列表中
                if inst.cell.name in macro_names:
                    # 记录该实例的位置
                    pos = inst.trans.disp
                    # 将结果添加到DataFrame中
                    new_row = pd.Series({"Macro Name": inst.cell.name, "X Origin": pos.x, "Y Origin": pos.y})
                    df = df._append(new_row, ignore_index=True)
                    print(new_row)

        # 将结果保存到CSV文件中
        df.to_csv(output_csv_file, index=False)
        print("Task completed successfully.")


root = Tk()
app = Application(root)
root.mainloop()
