import os

# 参数配置
queue_name = "dpd"  # 指定队列名称
num_cores = 4  # 指定系统核数

# 创建长时间运行的shell脚本内容
shell_script_content = f"""
#!/bin/bash
#BSUB -J long_running_job
#BSUB -q {queue_name}
#BSUB -n {num_cores}
#BSUB -o long_running_job.out
#BSUB -e long_running_job.err

sleep 86400  # 让作业睡眠24小时
"""

# 将脚本内容写入文件
script_filename = "long_run_job.sh"
with open(script_filename, "w") as script_file:
    script_file.write(shell_script_content)

# 提交作业到LSF系统
submit_command = f"bsub < {script_filename}"
os.system(submit_command)

print("Assignments have been submitted")
