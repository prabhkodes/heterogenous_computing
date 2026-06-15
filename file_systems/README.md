# HPC File Systems & Parallel I/O

Three projects covering parallel I/O patterns and filesystem performance relevant to HPC workloads.

## jacobi_io_parallel

Parallel Jacobi heat diffusion solver (MPI + OpenMP) that checkpoints to HDF5 using collective MPI-IO. Demonstrates how to write distributed in-memory grids (with ghost rows) to a single shared file efficiently. Includes a SLURM job script for running on a cluster.

## h5_stuff

Two focused programs showing the HDF5 parallel write pattern from scratch — one in C++, one in C. Good reference for the hyperslab selection + collective write workflow before integrating it into a larger solver.

## compare_fs_hpc

`fio` benchmarks comparing ext4, XFS, and Btrfs on sequential and random I/O patterns. Useful for understanding which filesystem to reach for depending on whether your workload is large streaming reads or small random writes.
