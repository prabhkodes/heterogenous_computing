#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>
#include <omp.h>
#include <cuda_runtime.h>

/***
 * Print usage
 ***/
void usage(char *argv[]){
  fprintf(stderr, "usage: %s N\n", argv[0]);
  return;
}

/***
 * Allocate memory; print error if NULL is returned
 ***/
void * ualloc(size_t size){
  void *ptr = malloc(size);
  if(ptr == NULL) {
    fprintf(stderr, "malloc() returned null; quitting...\n");
    exit(-2);
  }
  return ptr;
}


void * gpu_alloc(size_t size) {
  void * ptr;
  cudaError_t err = cudaMalloc(&ptr, size);
  if (err != cudaSuccess) {
    fprintf(stderr, "cudaMalloc returned %d , quitting from gpu_alloc .. \n", err);
    exit(-2);
  }
  return ptr;
}

/***
 * Return a random number in [0, 1)
 ***/
double urand(void){
  double x = (double)rand()/(double)RAND_MAX;
  return x;
}

/***
 * Return seconds elapsed since t0, with t0 = 0 the epoch
 ***/
double stop_watch(double t0){
  struct timeval t;
  gettimeofday(&t, NULL);
  return (double)t.tv_sec + (double)t.tv_usec/1e6 - t0;
}

__global__ void gpu_axpy(int n, float a, float *x, float *y) {

  int ithr = threadIdx.x;
  int nthr = blockDim.x;
  int iblk = blockIdx.x;
  int idx = ithr + iblk*nthr;

  if (idx < n) {
      y[idx] = a*x[idx] + y[idx];
  }

  return;
}


void axpy(int n, float a, float *x, float *y){

#pragma omp parallel for
  for(int i=0; i<n; i++)
    y[i] = a*x[i] + y[i];
  
  return;
}

int main(int argc, char *argv[]){
  if(argc != 2) {
    usage(argv);
    return 1;
  }

  unsigned long int n = atol(argv[1]);

  float *x0 = (float *)ualloc(sizeof(float)*n);
  float *x1 = (float *)ualloc(sizeof(float)*n);
  float *y0 = (float *)ualloc(sizeof(float)*n);
  float *y1 = (float *)ualloc(sizeof(float)*n);

  /*
   * Initialize a and arrays
   */
  srand(2147483647);
  float a = urand();

  for(int i=0; i<n; i++) {
    double rx = urand();
    x0[i] = rx;
    x1[i] = rx;

    double ry = urand();
    y0[i] = ry;
    y1[i] = ry;
  }

  /*
   * A: Run axpy(), return to y0, report performance
   */
  {
    double t0 = stop_watch(0);
    axpy(n, a, x0, y0);
    t0 = stop_watch(t0);

    double n_flop = 2;
    double n_io = 3*sizeof(float);
#pragma omp parallel
    {
#pragma omp single
      {
      int nthr = omp_get_num_threads();
      printf(" CPU: nthr = %4d   t0 = %6.4lf sec   P = %7.3lf Gflop/s   B = %7.3lf GB/s\n",
         nthr, t0, n_flop*n/1e9/t0, n_io*n/1e9/t0);
      }
    }
  }

  {
    
    float *d_x = (float *)gpu_alloc(sizeof(float) * n);
    float *d_y = (float *)gpu_alloc(sizeof(float) * n);

    cudaMemcpy(d_x, x1, sizeof(float) * n, cudaMemcpyHostToDevice);
    cudaMemcpy(d_y, y1, sizeof(float) * n, cudaMemcpyHostToDevice);

    double t0 = stop_watch(0);
    
    int nthr = 1024;
    int nblk = (n + nthr - 1) / nthr;

    gpu_axpy<<<nblk, nthr>>> (n, a, d_x, d_y);

    cudaDeviceSynchronize();
    
    t0 = stop_watch(t0);

    cudaMemcpy(y1, d_y, sizeof(float) * n, cudaMemcpyDeviceToHost);

    double n_flop = 2;
    double n_io   = 3*sizeof(float);

    // Report Performance
#pragma omp parallel
    {
#pragma omp single
      {
      int nthr = omp_get_num_threads();
      // Note: This reports Kernel calculation speed. If you want total transfer speed, 
      // you must move stop_watch calls to surround the cudaMemcpy calls as well.
      printf(" GPU: nthr = %4d   t0 = %6.4lf sec   P = %7.3lf Gflop/s   B = %7.3lf GB/s\n",
         nthr, t0, n_flop*n/1e9/t0, n_io*n/1e9/t0);
      }
    }

    // 5. Free Device Memory
    cudaFree(d_x);
    cudaFree(d_y);
  }

  /* Compare y1 and y0 */
  double diff = 0;
  double norm = 0;
  for(int i=0; i<n; i++) {
    float d = y0[i]-y1[i];
    diff += d*d;
    norm += y0[i]*y0[i];
  }
  printf(" Diff = %e\n", diff/norm);


  free(x0);
  free(x1);
  free(y0);
  free(y1);
  return 0;

}