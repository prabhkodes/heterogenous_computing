# Matrix Copy

This program demonstrates a 2D CUDA kernel that copies a matrix from input to output using parallel threads. Each thread handles one element of the matrix, demonstrating 2D block and grid organization for efficient memory access patterns.

## Compilation (Leonardo HPC)

Load the required modules and compile using the NVC++ compiler:


module load gcc/12.2.0
module load nvhpc/24.5

nvc++ main.cu -o main.x
