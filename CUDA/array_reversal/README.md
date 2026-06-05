# Array Reversal

This program demonstrates a CUDA kernel that reverses an array in parallel on the GPU. Each thread is responsible for swapping elements from opposite ends of the array using the GPU's parallel processing capabilities.

## Compilation (Leonardo HPC)

Load the required modules and compile using the NVC++ compiler:

module load gcc/12.2.0
module load nvhpc/24.5

nvc++ main.cu -o main.x
