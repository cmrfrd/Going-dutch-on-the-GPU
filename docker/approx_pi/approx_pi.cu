#include <iostream>
#include <limits>
#include <cuda.h>
#include <curand_kernel.h>

using std::cout;
using std::endl;

typedef unsigned long long Count;
typedef std::numeric_limits<double> DblLim;

const Count WARP_SIZE = 32;
const Count NBLOCKS = 64;
const Count ITERATIONS = 10000000;
const Count REPETITIONS = 400;

__global__ void monte_carlo_pi(Count *totals) {

  // Create shared memory for block
	__shared__ Count counter[WARP_SIZE];
	counter[threadIdx.x] = 0;

	// Unique ID of the thread
  // use this id to seed the rng for each thread
	int tid = threadIdx.x + blockIdx.x * blockDim.x;
	curandState_t rng;
	curand_init(clock64(), tid, 0, &rng);

	// Run through iterations, sample two uniform points,
  // then calculate test if points fall within circle
	for (int i = 0; i < ITERATIONS; i++) {
		float x = curand_uniform(&rng);
		float y = curand_uniform(&rng);
		counter[threadIdx.x] += 1 - int(x * x + y * y);
	}

	// In every block use the first thread to aggregate the results
  // using the shared memory within the block. Shared memory is fast!
	if (threadIdx.x == 0) {
		totals[blockIdx.x] = 0;
		for (int i = 0; i < WARP_SIZE; i++) {
			totals[blockIdx.x] += counter[i];
		}
	}
}

int main(int argc, char **argv) {

  // Set precision of cout numbers
  cout.precision(DblLim::max_digits10);

  // Check if there is a cuda device available
	int numDev;
	cudaGetDeviceCount(&numDev);
	if (numDev < 1) {
		cout << "CUDA device missing! Do you need to use optirun?\n";
		return 1;
	}

  // Log base params
	cout << "Starting monte carlo simulation with \n"
       << NBLOCKS << " blocks, \n"
       << WARP_SIZE << " threads, and \n"
       << ITERATIONS << " iterations, over \n"
       << REPETITIONS << " repetitions" << endl;

	// Allocate duplicate size host and device memory to store
  // the counts of each blocks monte carlo process
	Count *hostOutput, *deviceOutput;
	hostOutput = new Count[NBLOCKS]; // Host memory
	cudaMalloc(&deviceOutput, sizeof(Count) * NBLOCKS); // Device memory

	Count total = 0;
  Count tests = NBLOCKS * ITERATIONS * WARP_SIZE;

  for (int repetition = 1; repetition <= REPETITIONS; repetition++) {

    // Launch kernel
    monte_carlo_pi<<<NBLOCKS, WARP_SIZE>>>(deviceOutput);

    // Copy back memory used on device and free
    cudaMemcpy(hostOutput, deviceOutput, sizeof(Count) * NBLOCKS, cudaMemcpyDeviceToHost);

    // Compute total hits
    for (int i = 0; i < NBLOCKS; i++) {
      total += hostOutput[i];
    }

    // Set maximum precision for decimal printing
    cout << "π ≅ " << 4.0 * (double)total/(double)(tests * repetition)
         << endl;
  }

  // Free device and host memory and exit process
	cudaFree(deviceOutput);
  free(hostOutput);
	return 0;
}
