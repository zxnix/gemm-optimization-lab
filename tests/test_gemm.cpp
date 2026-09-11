#include "gemm/gemm.hpp"
#include "gemm/verification.hpp"

#include <cstdlib>
#include <exception>
#include <iostream>
#include <stdexcept>

namespace {

void require(bool condition, const char* message) {
    if (!condition) {
        throw std::runtime_error(message);
    }
}

void test_known_rectangular_case() {
    gemm::Matrix a(2, 3);
    gemm::Matrix b(3, 2);
    gemm::Matrix c(2, 2);

    a(0, 0) = 1.0F; a(0, 1) = 2.0F; a(0, 2) = 3.0F;
    a(1, 0) = 4.0F; a(1, 1) = 5.0F; a(1, 2) = 6.0F;
    b(0, 0) = 7.0F; b(0, 1) = 8.0F;
    b(1, 0) = 9.0F; b(1, 1) = 10.0F;
    b(2, 0) = 11.0F; b(2, 1) = 12.0F;

    gemm::gemm_naive(a, b, c);
    require(c(0, 0) == 58.0F && c(0, 1) == 64.0F &&
                c(1, 0) == 139.0F && c(1, 1) == 154.0F,
            "known rectangular GEMM result is wrong");
}

void test_random_rectangular_case() {
    gemm::Matrix a(7, 5);
    gemm::Matrix b(5, 9);
    gemm::Matrix c(7, 9);
    gemm::fill_random(a, 11U);
    gemm::fill_random(b, 29U);
    gemm::gemm_naive(a, b, c);
    require(gemm::verify_gemm(a, b, c).passed, "random rectangular GEMM verification failed");
}

void test_dimension_check() {
    gemm::Matrix a(2, 3);
    gemm::Matrix b(4, 2);
    gemm::Matrix c(2, 2);
    bool threw = false;
    try {
        gemm::gemm_naive(a, b, c);
    } catch (const std::invalid_argument&) {
        threw = true;
    }
    require(threw, "incompatible dimensions were not rejected");
}

}  // namespace

int main() {
    try {
        test_known_rectangular_case();
        test_random_rectangular_case();
        test_dimension_check();
        std::cout << "All GEMM tests passed.\n";
        return EXIT_SUCCESS;
    } catch (const std::exception& error) {
        std::cerr << "Test failure: " << error.what() << '\n';
        return EXIT_FAILURE;
    }
}
