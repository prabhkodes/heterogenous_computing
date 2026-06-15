# Matrix Copy

2D CUDA kernel that copies a matrix element-by-element using a grid of 16×16 thread blocks. Shows how to map a 2D thread index to a flat memory layout.

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
