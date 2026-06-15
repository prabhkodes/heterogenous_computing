# HDF5 Parallel I/O

Two standalone programs exploring parallel HDF5 writes using MPI-IO.

## Programs

**`test_hdf5.cpp`** — Each MPI rank owns a local array of 100 doubles and writes it into a contiguous 1D dataset in a shared HDF5 file using collective I/O (`H5FD_MPIO_COLLECTIVE`). Shows the basic pattern: file access property list → hyperslab selection per rank → collective `H5Dwrite`.

**`convert_IO.c`** — Converts an ASCII Jacobi output file to HDF5. Each rank reads only its portion of the text file, then all ranks write their rows collectively into a 2D `/temperature` dataset. Ghost rows are allocated locally but excluded from the file write via hyperslab selection.

## Build

```bash
make            # builds both test_hdf5.x and convert_IO.x
make run_cpp    # mpirun -n 4 ./test_hdf5.x
make run_c      # mpirun -n 4 ./convert_IO.x
make clean
```

Requires `hdf5-mpi` (`brew install hdf5-mpi` on macOS, or `module load hdf5` on a cluster).
