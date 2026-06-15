#!/bin/bash
#SBATCH --job-name=run_gpu
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --partition=longrun
#SBATCH --time=00:05:00
#SBATCH --output=slurm-%j.out
#SBATCH --error=slurm-%j.err
#SBATCH --exclusive

module load cuda/11.8

#nvcc -O3 -Xcompiler -fopenmp -o axpy.x axpy2.cu

nvcc -O3 -arch=native -use_fast_math -Xcompiler  -o axpy.x axpy.cu
srun ./axpy.x 1000000000

