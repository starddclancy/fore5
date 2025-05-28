import os

# Parameters
queue_name = "normal"  # Specify the queue name
num_cores = 4  # Specify the number of system cores

# Create the content for the long-running shell script
shell_script_content = f"""
#!/bin/bash
#BSUB -J large_scale_computation
#BSUB -q {queue_name}
#BSUB -n {num_cores}
#BSUB -o large_scale_computation.out
#BSUB -e large_scale_computation.err

# Load necessary modules or environments
# module load python/3.8  # Load modules as per your environment

# Resource-intensive computation task
python - << EOF
import numpy as np
from scipy.linalg import eigh
import time

# Define the matrix size
matrix_size = 20000

# Create a large random symmetric matrix
A = np.random.rand(matrix_size, matrix_size)
A = (A + A.T) / 2

# Perform eigenvalue decomposition
print("Starting eigenvalue decomposition...")
eigenvalues, eigenvectors = eigh(A)
print("Eigenvalue decomposition completed.")

# Output some statistics
print("Number of eigenvalues:", len(eigenvalues))
print("Smallest eigenvalue:", eigenvalues[0])
print("Largest eigenvalue:", eigenvalues[-1])

# Simulate additional heavy computation
for i in range(10):
    B = np.random.rand(matrix_size, matrix_size)
    C = np.dot(B, B.T)
    print(f"Iteration {i+1}: Matrix multiplication result has mean {np.mean(C)} and std {np.std(C)}")
    time.sleep(3600)  # Sleep for 1 hour per iteration

print("Computation task completed.")
EOF
"""

# Write the script content to a file
script_filename = "large_scale_computation.sh"
with open(script_filename, "w") as script_file:
    script_file.write(shell_script_content)

# Submit the job to the LSF system
submit_command = f"bsub < {script_filename}"
os.system(submit_command)

print("Job has been submitted.")
