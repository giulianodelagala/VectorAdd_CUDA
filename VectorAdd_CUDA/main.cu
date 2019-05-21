#include <iostream>
#include <time.h>
#include <math.h>

//#include <cuda.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

using std::cout; using std::cin;

//void ImpError(cudaError_t err);

void ImpError(cudaError_t err)
{
	cout << cudaGetErrorString(err); // << " en " << __FILE__ << __LINE__;
	//exit(EXIT_FAILURE);
}


__global__
void vecAddKernel(float* A, float* B, float* C, int n)
{
	int i = blockDim.x * blockIdx.x + threadIdx.x;
	if (i < n)
		C[i] = A[i] + B[i];
}


void vecAdd(float* A, float* B, float* C, int n)
{
	int size = n * sizeof(float);
	float* d_A, * d_B, * d_C;

	cudaError_t err = cudaSuccess;
	
	err = cudaMalloc((void**)& d_A, size);

	if (err != cudaSuccess)
	{
		cout << "d_A";
		ImpError(err);
	}
		

	err = cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);

	if (err != cudaSuccess)
		ImpError(err);

	err = cudaMalloc((void**)& d_B, size);

	if (err != cudaSuccess)
		ImpError(err);

	err = cudaMemcpy(d_B, B, size, cudaMemcpyHostToDevice);

	if (err != cudaSuccess)
		ImpError(err);

	err = cudaMalloc((void**)& d_C, size);

	if (err != cudaSuccess)
		ImpError(err);

	//<<#bloques,#threads por bloques>>
	vecAddKernel<<<ceil(n / 512.0), 512>>>(d_A, d_B, d_C, n);

	err = cudaMemcpy(C, d_C, size, cudaMemcpyDeviceToHost);

	if (err != cudaSuccess)
		ImpError(err);
	
	cudaFree(d_A); cudaFree(d_B); cudaFree(d_C);
}

void Imprimir(float* A, int n)
{
	for (int i = 0; i < n; ++i)
		if (i<n) cout << A[i] << " ";
	cout << "\n";
}

void GenVector(float* A, int n)
{
	
	for (int i = 0; i < n; ++i)
		A[i] = static_cast <float> (rand()) / (static_cast <float> (RAND_MAX / n));
}


int main(int argc, char** argv)
{
	int array_size = 10;
	
	float* A, * B, * C;
	srand(time(NULL));
	/*
	if (argc == 2)
	{
		array_size = strtof(argv[1], NULL);
	}
	else
		cout << "Ingrese array_size"; cin >> array_size;
	*/

	A = new float[array_size];
	B = new float[array_size];
	C = new float[array_size];

	GenVector(A, array_size);
	GenVector(B, array_size);
	
	vecAdd(A, B, C, array_size);

	Imprimir(A, array_size);
	Imprimir(B, array_size);
	Imprimir(C, array_size);

	//cudaDeviceSynchronize();

	return 0;
}