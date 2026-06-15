# Heterogeneous Computing

> Work from my HPC postgraduate program. Parallel algorithms, GPU kernels, distributed I/O, and performance analysis — all run on real hardware including **Leonardo Booster** (Cineca), one of the top supercomputers in Europe.

![C](https://img.shields.io/badge/C-00599C?style=flat&logo=c&logoColor=white)
![C++](https://img.shields.io/badge/C++20-00599C?style=flat&logo=cplusplus&logoColor=white)
![CUDA](https://img.shields.io/badge/CUDA-76B900?style=flat&logo=nvidia&logoColor=white)
![Fortran](https://img.shields.io/badge/Fortran-734F96?style=flat&logo=fortran&logoColor=white)
![MPI](https://img.shields.io/badge/MPI-OpenMPI-blue?style=flat)
![OpenMP](https://img.shields.io/badge/OpenMP-red?style=flat)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)
![SLURM](https://img.shields.io/badge/SLURM-HPC-orange?style=flat)

---

## 🖥️ CUDA

| Project | Description |
|---|---|
| [`CUDA/matrix_transpose`](CUDA/matrix_transpose) | Three transpose kernels side by side — naive, coalesced, and shared memory tiled. |
| [`CUDA/matrix_mult`](CUDA/matrix_mult) | GPU matrix multiplication with strong scaling benchmarks |
| [`CUDA/jacobian_solver`](CUDA/jacobian_solver) | Jacobi heat diffusion on GPU, profiled with Nsight Systems |
| [`CUDA/AXPY`](CUDA/AXPY) | AXPY benchmarked across K80 → P100 → V100 |
| [`CUDA/reduction`](CUDA/reduction) | Parallel reduction kernel |
| [`CUDA/array_reversal`](CUDA/array_reversal) | In-place reversal, one thread per element pair |
| [`CUDA/matrix_copy`](CUDA/matrix_copy) | 2D copy using 16×16 thread blocks |

## 📡 MPI

| Project | Description |
|---|---|
| [`open-mpi/cannon_mat_mult`](open-mpi/cannon_mat_mult) | Cannon's algorithm on a 2D Cartesian torus. MPI + OpenMP + OpenBLAS. 10k×10k, ~9s on 4 ranks. |
| [`open-mpi/job_scheduler`](open-mpi/job_scheduler) | Supervisor/worker scheduler — rank 0 dispatches to whichever worker finishes first |
| [`open-mpi/mpi_timer`](open-mpi/mpi_timer) | Benchmarks Send/Recv, Scatter, and one-sided Put — bulk vs element-by-element |
| [`open-mpi/matrix_overload_vector_mpi`](open-mpi/matrix_overload_vector_mpi) | Templated matrix class with `operator<<`, used across MPI ranks |

## 💾 File Systems & Parallel I/O

| Project | Description |
|---|---|
| [`file_systems/jacobi_io_parallel`](file_systems/jacobi_io_parallel) | Jacobi solver (MPI + OpenMP) checkpointing to HDF5 via collective MPI-IO. I/O latency breakdown across ranks. |
| [`file_systems/h5_stuff`](file_systems/h5_stuff) | Minimal HDF5 parallel write examples in C and C++ |
| [`file_systems/compare_fs_hpc`](file_systems/compare_fs_hpc) | `fio` benchmarks — ext4 vs XFS vs Btrfs on sequential and random I/O |

## ⚡ Optimisations

| Project | Description |
|---|---|
| [`optimisations/blocked_matrix_mult`](optimisations/blocked_matrix_multiplication) | Cache-blocked GEMM with roofline analysis, block size sweep, strong/weak scaling plots |
| [`optimisations/fft`](optimisations/fft) | Cooley-Tukey FFT from scratch in C, then ported to CUDA in 3 iterations. Benchmarked on P100. |
| [`optimisations/leonardo_booster`](optimisations/leonardo_booster) | Node topology (2 sockets, 8 NUMA nodes, A100s) and the pinning decisions it drove |

## 📦 Containers

| Project | Description |
|---|---|
| [`containers_hpc/jacobi_gpu`](containers_hpc/jacobi_gpu) | Jacobi solver (MPI + OpenACC) in Docker using the NVIDIA HPC SDK base image. Includes Nsight profiling script. |
| [`containers_hpc/fft`](containers_hpc/fft) | OpenMP FFT in Docker + Singularity, compiled for Ice Lake. Singularity for clusters that block Docker. |

## 🔢 Fortran

Data structures and sorting algorithms with a layered module system — quicksort, merge sort, hybrid sort, hash tables (C FFI via `ISO_C_BINDING`), linked lists, stacks, BST with rebalancing. → [`fortran/`](fortran)
