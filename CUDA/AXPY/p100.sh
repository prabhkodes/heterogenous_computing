#!/bin/bash
#SBATCH --job-name=run_gpu
#SBATCH --nodes=1
#SBATCH --gres=gpu:p100:1
#SBATCH --partition=skyvolta
#SBATCH --time=00:05:00
#SBATCH --output=slurm-%j.out
#SBATCH --error=slurm-%j.err
#SBATCH --exclusive

module load cuda/11.8


#nvcc -O3 -arch=native -use_fast_math -Xcompiler  -o axpy.x axpy.cu
nvcc axpy.cu -o axpy.x -Xcompiler -fopenmp -lm -arch=sm_60 -use_fast_math
srun ./axpy.x 1000000000