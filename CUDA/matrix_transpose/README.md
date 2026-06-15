# Matrix Transpose

Three kernels side by side: a naive copy, a naive transpose, and a shared memory transpose. The shared memory version loads a 16×16 tile into `__shared__` before writing transposed, avoiding uncoalesced global memory writes.

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
