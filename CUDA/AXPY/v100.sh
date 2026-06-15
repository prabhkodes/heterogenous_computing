#!/bin/bash
#BATCH --job-name=run_gpu
#SBATCH --nodes=1
#SBATCH --gres=gpu:v100:1
#SBATCH --partition=skyvolta
#SBATCH --time=00:05:00
#SBATCH --output=slurm-%j.out
#SBATCH --error=slurm-%j.err
#SBATCH --exclusive

module load cuda/11.8

#nvcc -O3 -arch=native -use_fast_math -Xcompiler  -o axpy.x axpy.cu
nvcc axpy.cu -o  axpy.x -Xcompiler -fopenmp -lm -arch=sm_70 -use_fast_math -O3
srun ./axpy.x 1000000000 

