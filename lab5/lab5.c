#include <stdio.h>
#include <stdlib.h>   
#include <time.h>     
#include <immintrin.h> 
#include <string.h>   
#include <math.h>     

// Define the number of elements in the array.
// Ensure this is a multiple of 4 for simpler SIMD processing without handling remainders.
#define NUM_ELEMENTS (1024 * 1024 * 8) // 8 Million floats (32MB)
#define NUM_RUNS 10                   // Number of times to run each test for averaging


void generate_random_floats(float* array, int size) {
    if (!array) return;
    for (int i = 0; i < size; i++) {
        array[i] = (float)rand() / (float)RAND_MAX * 100.0f; // Random floats between 0.0 and 100.0
    }
}


void vector_scale_sisd(const float* input_array, float* output_array, int size, float scalar) {
    // Using x87 FPU instructions to scale each element one by one
    for (int i = 0; i < size; i++) {
        asm volatile(
            "flds %2;"         // Load scalar onto the FPU stack
            "flds (%1);"       // Load input_array[i] onto the FPU stack
            "fmulp %%st(1), %%st;"  // Multiply and pop
            "fstps (%0);"      // Store result to output_array[i] and pop
            : // No output operands
            : "r" (&output_array[i]), "r" (&input_array[i]), "m" (scalar)
            : "memory"
        );
    }
}


void vector_scale_simd(const float* input_array, float* output_array, int size, float scalar) {
    // Prepare an aligned array for the broadcasted scalar.
    float scalar_broadcasted[4] __attribute__((aligned(16)));

    // Use inline assembly to broadcast the scalar value to all 4 positions
    asm volatile(
        "movss %1, %%xmm0;"      // Load scalar to lowest position of xmm0
        "shufps $0, %%xmm0, %%xmm0;" // Broadcast to all 4 positions (0,0,0,0 pattern)
        "movaps %%xmm0, %0;"     // Store to scalar_broadcasted array
        : "=m" (scalar_broadcasted)
        : "m" (scalar)
        : "xmm0"
    );

    // Process 4 floats at a time using SSE instructions
    for (int i = 0; i < size; i += 4) {
        asm volatile(
            "movaps (%1), %%xmm1;"   // Load 4 input values to xmm1
            "mulps (%2), %%xmm1;"    // Multiply by broadcasted scalar
            "movaps %%xmm1, (%0);"   // Store result to output
            : // No output operands
            : "r" (output_array + i), "r" (input_array + i), "r" (scalar_broadcasted)
            : "xmm1", "memory"
        );
    }
}


int main() {
    // Seed the random number generator
    srand((unsigned int)time(NULL));

    // Allocate memory for arrays. Use aligned_alloc for SIMD to ensure 16-byte alignment.
    float* input_array = (float*)aligned_alloc(16, NUM_ELEMENTS * sizeof(float));
    float* output_array_sisd = (float*)aligned_alloc(16, NUM_ELEMENTS * sizeof(float));
    float* output_array_simd = (float*)aligned_alloc(16, NUM_ELEMENTS * sizeof(float));

    if (!input_array || !output_array_sisd || !output_array_simd) {
        perror("Failed to allocate memory");
        if (input_array) free(input_array);
        if (output_array_sisd) free(output_array_sisd);
        if (output_array_simd) free(output_array_simd);
        return 1;
    }

    generate_random_floats(input_array, NUM_ELEMENTS);

    const float scalar_value = 3.14159f;
    struct timespec start_time, end_time;
    double time_taken_sisd_total = 0.0;
    double time_taken_simd_total = 0.0;
    double time_taken_sisd_avg_us, time_taken_simd_avg_us;

    printf("Starting SISD (x87 FPU) and SIMD (SSE) performance comparison for vector scaling (Inline Assembly)...\n");
    printf("Number of elements: %d\n", NUM_ELEMENTS);
    printf("Number of runs for averaging: %d\n", NUM_RUNS);
    printf("Scalar value: %f\n\n", scalar_value);

    // --- Measure SISD performance (with x87 FPU inline assembly) ---
    for (int run = 0; run < NUM_RUNS; ++run) {
        memset(output_array_sisd, 0, NUM_ELEMENTS * sizeof(float));
        clock_gettime(CLOCK_MONOTONIC, &start_time);
        vector_scale_sisd(input_array, output_array_sisd, NUM_ELEMENTS, scalar_value);
        clock_gettime(CLOCK_MONOTONIC, &end_time);
        time_taken_sisd_total += (double)(end_time.tv_sec - start_time.tv_sec) * 1e6 +
                                 (double)(end_time.tv_nsec - start_time.tv_nsec) / 1e3;
    }
    time_taken_sisd_avg_us = time_taken_sisd_total / NUM_RUNS;
    printf("Average SISD (x87 asm) execution time: %.3f microseconds (%.3f milliseconds)\n",
           time_taken_sisd_avg_us, time_taken_sisd_avg_us / 1000.0);

    // --- Measure SIMD performance (with SSE inline assembly) ---
    for (int run = 0; run < NUM_RUNS; ++run) {
        memset(output_array_simd, 0, NUM_ELEMENTS * sizeof(float));
        clock_gettime(CLOCK_MONOTONIC, &start_time);
        vector_scale_simd(input_array, output_array_simd, NUM_ELEMENTS, scalar_value);
        clock_gettime(CLOCK_MONOTONIC, &end_time);
        time_taken_simd_total += (double)(end_time.tv_sec - start_time.tv_sec) * 1e6 +
                                 (double)(end_time.tv_nsec - start_time.tv_nsec) / 1e3;
    }
    time_taken_simd_avg_us = time_taken_simd_total / NUM_RUNS;
    printf("Average SIMD (SSE asm) execution time: %.3f microseconds (%.3f milliseconds)\n",
           time_taken_simd_avg_us, time_taken_simd_avg_us / 1000.0);

    // --- Verification: Check if SISD and SIMD results match ---
    int errors = 0;
    for(int i=0; i < NUM_ELEMENTS; ++i) {
        if (fabs(output_array_sisd[i] - output_array_simd[i]) > 1e-5) { // Tolerance for float comparison
            errors++;
            if (errors < 10) {
                 printf("Mismatch at index %d: SISD=%.6f, SIMD=%.6f\n", i, output_array_sisd[i], output_array_simd[i]);
            }
        }
    }
    if(errors > 0) {
        printf("\nWARNING: %d mismatches found between SISD and SIMD results!\n", errors);
    } else {
        printf("\nVerification: SISD and SIMD results match.\n");
    }

    // --- Calculate and print speedup ---
    if (time_taken_simd_avg_us > 0 && time_taken_sisd_avg_us > 0) {
        double speedup = time_taken_sisd_avg_us / time_taken_simd_avg_us;
        printf("\nSIMD (SSE asm) Speedup over SISD (x87 asm): %.2fx\n", speedup);
    } else {
        printf("\nCould not calculate speedup (one of the execution times was zero or invalid).\n");
    }

    free(input_array);
    free(output_array_sisd);
    free(output_array_simd);

    return 0;
}