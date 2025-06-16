#include <stdio.h>
#include <stdlib.h>

// Declare the external assembly function
extern float sse_det4x4(float m[16]);

// A helper function to print the matrix
void print_matrix(const float *m) {
    printf("Matrix:\n");
    for (int i = 0; i < 4; ++i) {
        printf("  [ ");
        for (int j = 0; j < 4; ++j) {
            printf("%8.2f ", m[i * 4 + j]);
        }
        printf("]\n");
    }
    printf("\n");
}

int main() {
    // Define a 4x4 matrix in row-major order.
    // The determinant of this matrix is -24.
    float matrix[16] __attribute__((aligned(16))) = {
    2.0f,  3.0f, 1.0f,  4.0f,
    5.0f, 2.0f,  3.0f,  1.0f,
   3.0f,  2.0f,  4.0f, 5.0f,
    1.0f, 3.0f,  2.0f,  6.0f
};
    
    // Print the matrix we are testing
    print_matrix(matrix);

    // Call the assembly function to calculate the determinant
    float determinant = sse_det4x4(matrix);

    // Print the result
    printf("Calculated determinant: %.4f\n", determinant);
    
    // Another test with a singular matrix (determinant = 0)
    printf("\n--- Another Test ---\n");
    float singular_matrix[16] __attribute__((aligned(16))) = {
    1.0f,  0.0f, -0.0f,  0.0f,
    0.0f, 3.0f,  0.0f,  0.0f,
   0.0f,  0.0f,  2.0f, 0.0f,
    0.0f, -0.0f,  0.0f,  1.0f
};
    print_matrix(singular_matrix);
    determinant = sse_det4x4(singular_matrix);
    printf("Calculated determinant: %.4f\n", determinant);


    return 0;
}
