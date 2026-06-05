# Matrix Transpose with Shared Memory

This program demonstrates matrix transposition using CUDA with shared memory optimization. The kernel transposes a matrix while leveraging shared memory to improve cache efficiency and reduce global memory access patterns.

## Compilation (Leonardo HPC)

Load the required modules and compile using the NVC++ compiler:

module load gcc/12.2.0
module load nvhpc/24.5

nvc++ main.cu -o main.x

