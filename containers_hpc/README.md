# Containers for HPC

HPC clusters typically don't let you install software freely, and environment modules can differ between systems. These projects package the build environment into containers so the same image runs consistently on any cluster that supports Docker or Singularity.

## Projects

### jacobi_gpu

Jacobi heat diffusion solver (MPI + OpenACC) offloaded to GPU. The Dockerfile uses the NVIDIA HPC SDK base image (`nvcr.io/nvidia/nvhpc`) so `nvc++` and MPI are available without any module setup. Includes a SLURM job script and an Nsight Systems profiling script for performance analysis on Leonardo.

### fft

Cooley-Tukey FFT in C, with a serial version and an OpenMP version. Packaged in both Docker (`Dockerfile`) and Singularity (`fft_openmp.def`). The image compiles for Intel Ice Lake (`-march=icelake-server`) to match Leonardo's CPU nodes.
