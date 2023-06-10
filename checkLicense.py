import os
import re
import glob
import smtplib
from datetime import datetime, timedelta
from email.message import EmailMessage

# 替换为实际的license文件所在目录路径（使用Windows路径）
license_dir = r"C:\Users\clancywang\Desktop\flies\license\nowInstall"

# 获取目录下所有txt文件
license_files = glob.glob(os.path.join(license_dir, "*.txt"))

# 设置提醒阈值
reminder_days = 7

# 获取当前日期
current_date = datetime.now()

# 邮件设置
email_sender = "your@email.com"
email_password = "your_password"
email_recipient = "recipient@email.com"
email_subject = "License过期提醒"
email_server = "smtp.your_email_server.com"
email_port = 587

# 处理每个license文件
for license_file in license_files:
    with open(license_file, "r") as f:
        content = f.read()

    # 提取过期日期和名字
    entries = re.findall(r"(FEATURE|INCREMENT)\s+(\S+)\s+\S+\s+\S+\s+([0-9]{2}-[a-zA-Z]{3}-[0-9]{4})", content, re.IGNORECASE)

    for entry in entries:
        name = entry[1]
        expiry_date = entry[2]
        expiry_date = datetime.strptime(expiry_date, "%d-%b-%Y")

        # 计算剩余天数
        days_left = (expiry_date - current_date).days

        # 判断是否需要提醒
        if days_left <= reminder_days:
            # 创建邮件
            msg = EmailMessage()
            msg.set_content(f"License（{name}）Will expire in {days_left} days")
            msg["Subject"] = email_subject
            msg["From"] = email_sender
            msg["To"] = email_recipient

            # 发送邮件
            print(f"License {name} Will expire in {days_left} days")
            with smtplib.SMTP(email_server, email_port) as server:
                server.starttls()
                server.login(email_sender, email_password)
                server.send_message(msg)




