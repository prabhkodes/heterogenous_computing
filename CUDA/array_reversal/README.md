# Array Reversal

CUDA kernel that reverses an array in-place on the GPU. Each thread swaps one pair of elements from opposite ends, so the whole array is reversed in a single parallel pass.

## Build & Run

```bash
# On a cluster
module load gcc/12.2.0
module load nvhpc/24.5
nvc++ main.cu -o main.x

# With nvcc
nvcc main.cu -o main.x

./main.x
```
