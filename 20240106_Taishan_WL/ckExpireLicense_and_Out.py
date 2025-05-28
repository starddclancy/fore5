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
            print(f"File: {file_path}, Name: {match[1]}, Remaining Days: {remaining_days}\n")
            log_file.write(f"File: {file_path}, Name: {match[1]}, Remaining Days: {remaining_days}\n")

folder_path = r'C:\Users\clancywang\Desktop\flies\license\nowInstall'
today = datetime.today().strftime('%Y-%m-%d')
yesterday = (datetime.today() - timedelta(days=1)).strftime('%Y-%m-%d')

log_file_name = f"log_{today}.txt"
backup_file_name = f"log_{yesterday}_backup.txt"

# Rename yesterday's log file for backup
if os.path.exists(os.path.join(folder_path, f"log_{yesterday}.txt")):
    os.rename(os.path.join(folder_path, f"log_{yesterday}.txt"), os.path.join(folder_path, backup_file_name))

# Open today's log file for writing
with open(os.path.join(folder_path, log_file_name), 'w') as log_file:
    # Iterate over all files in the specified folder
    for filename in os.listdir(folder_path):
        if filename.endswith('.txt'):
            file_path = os.path.join(folder_path, filename)
            process_file(file_path, log_file)
