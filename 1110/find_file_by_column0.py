# Sample code to match the first column of a CSV file with filenames in a directory
# and append the filenames and their paths to the CSV.

import pandas as pd
import os

# Path to the directory containing files (replace with the actual path)
directory_path = '/path/to/directory'

# Path to the CSV file (replace with the actual path)
csv_path = '/path/to/csv_file.csv'

# Load the CSV file
df = pd.read_csv(csv_path)

# Add new columns for filename and file path
df['Filename'] = ''
df['Filepath'] = ''

# Iterate over each row in the DataFrame
for index, row in df.iterrows():
    search_term = row[0]  # Assuming the first column contains the search term
    found = False

    # Iterate over each file in the directory
    for filename in os.listdir(directory_path):
        if search_term in filename:
            # Update the DataFrame with filename and path
            df.at[index, 'Filename'] = filename
            df.at[index, 'Filepath'] = os.path.join(directory_path, filename)
            found = True
            break

    if not found:
        # Leave Filename and Filepath columns blank if no file is found
        df.at[index, 'Filename'] = ''
        df.at[index, 'Filepath'] = ''

# Save the updated DataFrame back to CSV
df.to_csv(csv_path, index=False)

# Display the updated DataFrame
df.head()
