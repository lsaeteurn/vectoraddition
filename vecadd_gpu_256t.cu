#include <iostream>
#include <math.h>

// Kernel function to add the elements of two arrays
__global__
void add(int n, float *x, float *y)
{
  int index = threadIdx.x;  //index of the current thread within its block
  int stride = blockDim.x;  //number of threads in the block
  for (int i = index; i < n; i += stride) //stride through the array with parallel threads.
      y[i] = x[i] + y[i];
}

int main(void)
{
  int N = 1<<26; // 64M elements
  float *x, *y;

  // Allocate Unified Memory – accessible from CPU or GPU
  cudaMallocManaged(&x, N*sizeof(float));
  cudaMallocManaged(&y, N*sizeof(float));

 // initialize x and y arrays on the host
  for (int i = 0; i < N; i++) {
    x[i] = 1.0f;
    y[i] = 2.0f;
  }
  add<<<1, 256>>>(N, x, y); //changed thread size

  // Wait for GPU to finish before accessing on host
  cudaDeviceSynchronize();

  // Check for errors (all values should be 3.0f)
  float maxError = 0.0f;
  for (int i = 0; i < N; i++)
    maxError = fmax(maxError, fabs(y[i]-3.0f));
  std::cout << "Max error: " << maxError << std::endl;
  
 // Free memory
  cudaFree(x);
  cudaFree(y);

  return 0;
}