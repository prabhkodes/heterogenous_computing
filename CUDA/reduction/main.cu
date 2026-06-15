#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>
#include <cuda_runtime.h>
#include <omp.h>

// --- HELPER FUNCTIONS ---

void usage(char *argv[]){
  fprintf(stderr, "usage: %s N\n", argv[0]);
  exit(1);
}

void * ualloc(size_t size){
  void *ptr = malloc(size);
  if(ptr == NULL) {
    fprintf(stderr, "malloc() returned null; quitting...\n");
    exit(-2);
  }
  return ptr;
}

double urand(void){
  return (double)rand()/(double)RAND_MAX;
}

double stop_watch(double t0){
  struct timeval t;
  gettimeofday(&t, NULL);
  return (double)t.tv_sec + (double)t.tv_usec/1e6 - t0;
}

float reduce_sum_cpu(unsigned long int n, int *data){
  int result;
  #pragma omp parallel for reduction(+:result)
  for(unsigned long int i=0; i<n; i++)
    result += data[i];
  return result;
}

// --- CUDA KERNELS ---

__global__ void reduce_v0(int *input, int *blockResults, int elementsPerThread) {
 unsigned int tid = blockIdx.x * blockDim.x + threadIdx.x;
 unsigned int startIdx = tid * elementsPerThread;
 int localSum = 0;

 // Each thread processes elementsPerThread elements
 for (unsigned int i = startIdx; i < startIdx + elementsPerThread; i++) {
 localSum += input[i];
 }
 // Accumulate into global result
 atomicAdd(&blockResults[blockIdx.x], localSum);
}

__global__ void reduce_v1(int *input, int *blockResults, int n) {
    extern __shared__ int sdata[];
    unsigned int tid = threadIdx.x;
    unsigned int globalIdx = blockIdx.x * blockDim.x + threadIdx.x;
    
    sdata[tid] =  input[globalIdx];
    __syncthreads();

    for (unsigned int s = 1; s < blockDim.x; s *= 2) {
        __syncthreads();
        if (threadIdx.x % (2 * s) == 0) {
            sdata[tid] += sdata[tid + s];
        }
    }
    __syncthreads();
    if (tid == 0) blockResults[blockIdx.x] = sdata[0];
}

__global__ void reduce_v2(int *input, int *blockResults, int n) {
    extern __shared__ int sdata[];
    unsigned int tid = threadIdx.x;
    unsigned int globalIdx = blockIdx.x * blockDim.x + threadIdx.x;
    
    sdata[tid] =  input[globalIdx];
    __syncthreads();

    for (unsigned int s = blockDim.x / 2; s > 0; s >>= 1) {
        if (tid < s) {
            sdata[tid] += sdata[tid + s];
        }
        __syncthreads();
    }
    if (tid == 0) blockResults[blockIdx.x] = sdata[0];
}

// --- MAIN ---

int main(int argc, char *argv[]) {
  if(argc != 2) usage(argv);

  unsigned long int n = atol(argv[1]);
  printf("Elements: %lu\n", n);

  // 1. Host Memory
  int *x = (int *)ualloc(sizeof(int)*n);
  
  srand(2147483647);
  for(unsigned long int i=0; i<n; i++) x[i] = (int)urand();

  int s0 = 0.0f; 

  // CPU Reference
  {
    double t0 = stop_watch(0);
    s0 = reduce_sum_cpu(n, x);
    t0 = stop_watch(t0);
    printf("\n[CPU OpenMP]\n");
    printf("  t0 = %6.4lf sec   P = %7.3lf Gflop/s   B = %7.3lf GB/s   Sum = %.2f\n",
           t0, n/1e9/t0, sizeof(float)*n/1e9/t0, s0);
  }

  // GPU Setup
  int blockSize = 256;
  int gridSize = (n + blockSize - 1) / blockSize;
  int *d_in, *d_block_results;
  
  // Allocate max possible result size (for V0, V1, V2)
  int *h_block_results = (int *)ualloc(gridSize * sizeof(int));

  cudaMalloc(&d_in, n * sizeof(int));
  cudaMalloc(&d_block_results, gridSize * sizeof(int));
  cudaMemcpy(d_in, x, n * sizeof(int), cudaMemcpyHostToDevice);

  // --- Run V0 (Atomic) ---
  {
      cudaMemset(d_block_results, 0, gridSize * sizeof(int));
      double t0 = stop_watch(0);
      
      reduce_v0<<<gridSize, blockSize>>>(d_in, d_block_results, n);
      cudaDeviceSynchronize();
      
      double elapsed = stop_watch(t0);

      // Verify
      cudaMemcpy(h_block_results, d_block_results, gridSize * sizeof(int), cudaMemcpyDeviceToHost);
      int s1;
      for(int k=0; k < gridSize; k++) s1 += h_block_results[k];
      
      double diff = (double)(s0 - s1);
      double err = (diff*diff)/((double)s0*s0);
      
      printf("[GPU V0 (Atomic)]\n");
      printf("  t0 = %6.4lf sec   B = %7.3lf GB/s   Diff = %e\n", 
             elapsed, sizeof(float)*n/1e9/elapsed, err);
  }

  // --- Run V1 (Interleaved) ---
  {
      double t0 = stop_watch(0);
      
      reduce_v1<<<gridSize, blockSize, blockSize*sizeof(int)>>>(d_in, d_block_results, n);
      cudaDeviceSynchronize();
      
      double elapsed = stop_watch(t0);

      cudaMemcpy(h_block_results, d_block_results, gridSize * sizeof(int), cudaMemcpyDeviceToHost);
      int s1;
      for(int k=0; k < gridSize; k++) s1 += h_block_results[k];
      
      double diff = (double)(s0 - s1);
      double err = (diff*diff)/((double)s0*s0);

      printf("[GPU V1 (Interleaved)]\n");
      printf("  t0 = %6.4lf sec   B = %7.3lf GB/s   Diff = %e\n", 
             elapsed, sizeof(float)*n/1e9/elapsed, err);
  }

  // --- Run V2 (Sequential) ---
  {
      double t0 = stop_watch(0);
      
      reduce_v2<<<gridSize, blockSize, blockSize*sizeof(int)>>>(d_in, d_block_results, n);
      cudaDeviceSynchronize();
      
      double elapsed = stop_watch(t0);

      cudaMemcpy(h_block_results, d_block_results, gridSize * sizeof(int), cudaMemcpyDeviceToHost);
      int s1;
      for(int k=0; k < gridSize; k++) s1 += h_block_results[k];
      
      double diff = (double)(s0 - s1);
      double err = (diff*diff)/((double)s0*s0);

      printf("[GPU V2 (Sequential)]\n");
      printf("  t0 = %6.4lf sec   B = %7.3lf GB/s   Diff = %e\n", 
             elapsed, sizeof(float)*n/1e9/elapsed, err);
  }


  free(x);
  free(h_block_results);
  cudaFree(d_in);
  cudaFree(d_block_results);
  
  return 0;
}