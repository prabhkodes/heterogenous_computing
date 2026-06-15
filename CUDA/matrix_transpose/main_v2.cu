#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>
#include <cuda_runtime.h>

#define TILE_DIM 32

// Timer
double stop_watch(double t0) {
    struct timeval t;
    gettimeofday(&t, NULL);
    return (double)t.tv_sec + (double)t.tv_usec / 1e6 - t0;
}

// CPU Reference
void cpu_transpose(float *in, float *out, int m, int n) {
    for (int i = 0; i < m; i++)
        for (int j = 0; j < n; j++)
            out[j * m + i] = in[i * n + j];
}

// GPU Naive
__global__ void transposeNaive(float *in, float *out, int width, int height) {
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;

    if (col < width && row < height) {
        int in_idx = row * width + col;
        int out_idx = col * height + row;
        out[out_idx] = in[in_idx];
    }
}

// GPU Shared Memory
__global__ void transposeShared(float *in, float *out, int width, int height) {
    __shared__ float tile[TILE_DIM][TILE_DIM + 1];

    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;

    if (col < width && row < height)
        tile[threadIdx.y][threadIdx.x] = in[row * width + col];

    __syncthreads();

    col = blockIdx.y * TILE_DIM + threadIdx.x;
    row = blockIdx.x * TILE_DIM + threadIdx.y;

    if (col < height && row < width)
        out[row * height + col] = tile[threadIdx.x][threadIdx.y];
}

int main(int argc, char *argv[]) {
    if (argc != 3) return 1;

    int m = atoi(argv[1]);
    int n = atoi(argv[2]);
    size_t bytes = m * n * sizeof(float);

    float *h_in = (float *)malloc(bytes);
    float *h_cpu = (float *)malloc(bytes);
    float *h_gpu = (float *)malloc(bytes);

    for (int i = 0; i < m * n; i++) h_in[i] = (float)rand() / RAND_MAX;

    // 1. CPU Reference
    cpu_transpose(h_in, h_cpu, m, n);

    float *d_in, *d_out;
    cudaMalloc(&d_in, bytes);
    cudaMalloc(&d_out, bytes);
    cudaMemcpy(d_in, h_in, bytes, cudaMemcpyHostToDevice);

    dim3 dimBlock(TILE_DIM, TILE_DIM);
    dim3 dimGrid((n + TILE_DIM - 1) / TILE_DIM, (m + TILE_DIM - 1) / TILE_DIM);

    // 2. GPU Naive
    double t0 = stop_watch(0);
    transposeNaive<<<dimGrid, dimBlock>>>(d_in, d_out, n, m);
    cudaDeviceSynchronize();
    double t_naive = stop_watch(t0);

    cudaMemcpy(h_gpu, d_out, bytes, cudaMemcpyDeviceToHost);
    
    // Check Naive Error
    double err_naive = 0;
    for (int i = 0; i < m * n; i++) err_naive += (h_cpu[i] - h_gpu[i]) * (h_cpu[i] - h_gpu[i]);

    // 3. GPU Shared
    t0 = stop_watch(0);
    transposeShared<<<dimGrid, dimBlock>>>(d_in, d_out, n, m);
    cudaDeviceSynchronize();
    double t_shared = stop_watch(t0);

    cudaMemcpy(h_gpu, d_out, bytes, cudaMemcpyDeviceToHost);

    // Check Shared Error
    double err_shared = 0;
    for (int i = 0; i < m * n; i++) err_shared += (h_cpu[i] - h_gpu[i]) * (h_cpu[i] - h_gpu[i]);

    // Report
    double gb = 2.0 * bytes / 1e9;
    printf("Naive:  %6.4f s | %6.2f GB/s | Err: %e\n", t_naive, gb / t_naive, err_naive);
    printf("Shared: %6.4f s | %6.2f GB/s | Err: %e\n", t_shared, gb / t_shared, err_shared);

    free(h_in); free(h_cpu); free(h_gpu);
    cudaFree(d_in); cudaFree(d_out);
    return 0;
}