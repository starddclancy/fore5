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
#BSUB -R "rusage[mem=32GB]"  # Request 32GB of memory

# Load necessary modules or environments
# module load python/3.8  # Load modules as per your environment

# Resource-intensive computation task
python - << 'EOF'
import numpy as np
import time

# Define the matrix size and number of matrices to consume 32GB memory
matrix_size = 20000
num_matrices = 10  # Number of matrices to ensure high memory usage

# Calculate the duration of the script to be 24 hours (86400 seconds)
start_time = time.time()
end_time = start_time + 86400  # 24 hours in seconds

# Initialize the matrices
print("Initializing matrices...")
matrices = [np.random.rand(matrix_size, matrix_size) for _ in range(num_matrices)]
print("Matrices initialized.")

# Perform heavy computation
iteration = 0
while time.time() < end_time:
    for i in range(num_matrices):
        A = matrices[i]
        B = np.dot(A, A.T)
        C = np.linalg.inv(B + np.eye(matrix_size) * 1e-10)
        D = np.dot(B, C)
        E = np.linalg.eigh(D)
        print(f"Iteration {{iteration}}, Matrix {{i}}: E mean: {{np.mean(D)}}, Eigenvalues mean: {{np.mean(E[0])}}")
        del B, C, D, E
    iteration += 1

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
