#include <cuda.h>
#include <R.h>

#define ITERATIONS 200
#define BLOCK_X 16
#define BLOCK_Y 16

typedef struct {
    double re;
    double im;
} complex;

__device__ complex zero()
{
    complex res;
    res.re = 0.0;
    res.im = 0.0;
    return res;
}

__device__ complex add(complex a, complex b) 
{
    complex res;
    res.re = a.re + b.re;
    res.im = a.im + b.im;
    return res;
}

__device__ complex mul(complex a, complex b)
{
    complex res;
    res.re = a.re * b.re - a.im * b.im;
    res.im = a.re * b.im + a.im * b.re;
    return res;
}

__device__ double square_mod(complex c)
{
    return c.re * c.re + c.im * c.im;
}

__device__ double color(complex c)
{
    complex z = zero();
    for (int i = 1; i <= ITERATIONS; ++i) {
        if (square_mod(z) >= 4.0) {
            return (1.0 - (double)i / ITERATIONS);
        }
        z = add(mul(z, z), c);
    }
    return 0.0;
}

__global__ void kernel(double *buffer, int cols, int rows, double sr, double dr, double si, double di)
{
    int col = threadIdx.x + blockIdx.x * blockDim.x;
    int row = threadIdx.y + blockIdx.y * blockDim.y;

    int offset = row + col * rows;

    if (offset < cols * rows) {

        complex c;
        c.re = sr + dr * col;
        c.im = si + di * row;

        buffer[offset] = color(c);
    }
}

extern "C" void mandel_gpu(int *w, int *h, double *sr, double *er, double *si, double *ei, double *result) 
{
    cudaError_t err;
    double* buffer = 0;
    err = cudaMalloc((void**)&buffer, (*w) * (*h) * sizeof(double));
    if (err != cudaSuccess) {
        Rprintf("cudaMalloc error: %d [%s]\n", err, cudaGetErrorString(err));
        return;
    }

    double dr = (*er - *sr) / *w;
    double di = (*ei - *si) / *h;

    dim3 blocks( ((*w) + BLOCK_X - 1) / BLOCK_X, ((*h) + BLOCK_Y - 1) / BLOCK_Y);
    dim3 threads(BLOCK_X, BLOCK_Y);
    kernel<<<blocks, threads>>>(buffer, *w, *h, *sr, dr, *si, di);

    err = cudaMemcpy(result, buffer, (*w) * (*h) * sizeof(double), cudaMemcpyDeviceToHost);
    cudaFree(buffer);
    if (err != cudaSuccess) {
        Rprintf("cudaMemcpy error: %d [%s]\n", err, cudaGetErrorString(err));
    }
}