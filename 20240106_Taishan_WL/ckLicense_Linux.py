import os
import re
from datetime import datetime, timedelta

def days_until_target(date_str):
    """Calculate days from today to the target date."""
    target_date = datetime.strptime(date_str, "%d-%b-%Y")
    return (target_date - datetime.today()).days

def process_file(file_path, log_file):
    with open(file_path, 'r') as file:
        text = file.read()

    pattern = r'(FEATURE|INCREMENT) (\w+) .*? (\d{1,2}-\w{3}-\d{4}) (\d+)'
    matches = re.findall(pattern, text)

    for match in matches:
        remaining_days = days_until_target(match[2])
        if remaining_days < 10:
            log_file.write(f"File: {file_path}, Name: {match[1]}, Remaining Days: {remaining_days}\n")

def delete_old_logs(folder_path, today_log, yesterday_log):
    for filename in os.listdir(folder_path):
        if filename.startswith("log_") and filename != today_log and filename != yesterday_log:
            os.remove(os.path.join(folder_path, filename))

# List of files you want to process
files_to_process = [
    '/path/to/first/file.txt',
    '/path/to/second/file.txt',
    '/path/to/third/file.txt'
]

log_folder = 'path_to_your_log_folder'
today = datetime.today().strftime('%Y-%m-%d')
yesterday = (datetime.today() - timedelta(days=1)).strftime('%Y-%m-%d')

log_file_name = f"log_{today}.txt"
backup_file_name = f"log_{yesterday}.txt"

# Rename yesterday's log file for backup
if os.path.exists(os.path.join(log_folder, f"log_{yesterday}.txt")):
    os.rename(os.path.join(log_folder, f"log_{yesterday}.txt"), os.path.join(log_folder, backup_file_name))

# Delete all log files except today's and yesterday's
delete_old_logs(log_folder, log_file_name, backup_file_name)

# Open today's log file for writing
with open(os.path.join(log_folder, log_file_name), 'w') as log_file:
    for file_path in files_to_process:
        process_file(file_path, log_file)