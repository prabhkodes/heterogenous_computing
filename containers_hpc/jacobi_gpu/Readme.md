# Jacobi GPU (MPI + OpenACC, containerised)

2D Jacobi heat diffusion solver offloaded to GPU via OpenACC, with MPI for multi-node distribution. Built and run inside a container so it runs portably on GPU clusters without manual environment setup.

## Build & Run (Docker)

```bash
docker build -t jacobi_gpu .
docker run --gpus all jacobi_gpu
```

## Build & Run (cluster, no container)

```bash
module load gcc/12.2.0 openmpi nvhpc/24.5

mpic++ -O3 -acc -gpu=cc80 -std=c++20 -Iinclude src/main.cpp -o app.x

export OMP_NUM_THREADS=4
mpirun -n 4 ./app.x jacobian.in
```

For multi-node runs, use the provided SLURM script:

```bash
sbatch job.sh
```

`jacobian.in` sets the grid size, corner heat value, steps, and print interval.

