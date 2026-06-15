# Parallel Jacobi Solver with HDF5 I/O (MPI + OpenMP)

2D heat diffusion solved iteratively with the Jacobi method, distributed row-wise across MPI ranks with OpenMP threading on each rank. Every `print_interval` steps, all ranks write their local tile into a single shared HDF5 file using collective MPI-IO. Per-phase timings (halo exchange, stencil, HDF5 write) are gathered across all ranks and written to `statistics.txt`.

## Build & Run

Requires `open-mpi`, `hdf5-mpi`, `libomp`.

```bash
make
make run              # mpirun -n 4, OMP_NUM_THREADS=2
make run NP=8 OMP=4
make clean
```

On a cluster:

```bash
module load gcc openmpi hdf5
make
mpirun -n 4 ./main.x jacobian.in
```

`jacobian.in` sets the grid size, corner heat value, number of steps, and checkpoint interval.

## Output

Checkpoints are written to `files/T_<step>.h5`, dataset `/temperature`.

```bash
h5dump files/T_0500.h5
gnuplot animate_jacobi.gp   # produce jacobi.gif
```
