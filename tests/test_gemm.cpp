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

void test_ikj_random_rectangular_case() {
    gemm::Matrix a(7, 5);
    gemm::Matrix b(5, 9);
    gemm::Matrix c(7, 9);
    gemm::fill_random(a, 11U);
    gemm::fill_random(b, 29U);
    gemm::gemm_ikj(a, b, c);
    require(gemm::verify_gemm(a, b, c).passed, "i-k-j GEMM verification failed");
}

void test_blocked_random_rectangular_case() {
    gemm::Matrix a(7, 5);
    gemm::Matrix b(5, 9);
    gemm::Matrix c(7, 9);
    gemm::fill_random(a, 11U);
    gemm::fill_random(b, 29U);
    gemm::gemm_blocked(a, b, c, 2);
    require(gemm::verify_gemm(a, b, c).passed, "blocked GEMM verification failed");
}

void test_packed_random_rectangular_case() {
    gemm::Matrix a(7, 5);
    gemm::Matrix b(5, 9);
    gemm::Matrix c(7, 9);
    gemm::fill_random(a, 11U);
    gemm::fill_random(b, 29U);
    gemm::PackedB packed_b(5, 9, 4);
    gemm::pack_b(b, packed_b);
    gemm::gemm_packed_b(a, packed_b, c);
    require(gemm::verify_gemm(a, b, c).passed, "packed GEMM verification failed");
}

void test_packed_layout_and_padding() {
    gemm::Matrix b(3, 3);
    float value = 1.0F;
    for (std::size_t k = 0; k < 3; ++k)
        for (std::size_t j = 0; j < 3; ++j)
            b(k, j) = value++;

    gemm::PackedB packed_b(3, 3, 2);
    gemm::pack_b(b, packed_b);
    const float* data = packed_b.data();
    require(data[0] == 1.0F && data[1] == 2.0F &&
                data[2] == 4.0F && data[3] == 5.0F,
            "first packed B tile has the wrong layout");
    require(data[4] == 3.0F && data[5] == 0.0F &&
                data[6] == 6.0F && data[7] == 0.0F,
            "packed B edge padding is wrong");
}

void test_packed_dimension_checks() {
    bool zero_block_threw = false;
    try {
        const gemm::PackedB invalid(3, 3, 0);
        (void)invalid;
    } catch (const std::invalid_argument&) {
        zero_block_threw = true;
    }
    require(zero_block_threw, "zero packed block size was not rejected");

    gemm::Matrix b(3, 4);
    gemm::PackedB wrong_shape(3, 5, 2);
    bool shape_threw = false;
    try {
        gemm::pack_b(b, wrong_shape);
    } catch (const std::invalid_argument&) {
        shape_threw = true;
    }
    require(shape_threw, "mismatched packed B dimensions were not rejected");
}

void test_one_by_one_case() {
    gemm::Matrix a(1, 1), b(1, 1), c(1, 1);
    a(0, 0) = 3.0F; b(0, 0) = -2.0F;
    gemm::gemm_naive(a, b, c);
    require(c(0, 0) == -6.0F, "1x1 GEMM result is wrong");
}

void test_zero_and_identity_cases() {
    gemm::Matrix a(3, 3), identity(3, 3), c(3, 3);
    gemm::fill_random(a, 41U);
    for (std::size_t i = 0; i < 3; ++i) identity(i, i) = 1.0F;
    gemm::gemm_naive(a, identity, c);
    for (std::size_t i = 0; i < 3; ++i)
        for (std::size_t j = 0; j < 3; ++j)
            require(c(i, j) == a(i, j), "identity GEMM result is wrong");

    gemm::Matrix zero(3, 2), output(3, 2);
    gemm::gemm_naive(a, zero, output);
    for (std::size_t i = 0; i < 3; ++i)
        for (std::size_t j = 0; j < 2; ++j)
            require(output(i, j) == 0.0F, "zero GEMM result is wrong");
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

void test_zero_dimension_check() {
    bool threw = false;
    try {
        const gemm::Matrix invalid(0, 3);
        (void)invalid;
    } catch (const std::invalid_argument&) {
        threw = true;
    }
    require(threw, "zero matrix dimension was not rejected");
}

}  // namespace

int main() {
    try {
        test_known_rectangular_case();
        test_random_rectangular_case();
        test_ikj_random_rectangular_case();
        test_blocked_random_rectangular_case();
        test_packed_random_rectangular_case();
        test_packed_layout_and_padding();
        test_packed_dimension_checks();
        test_one_by_one_case();
        test_zero_and_identity_cases();
        test_dimension_check();
        test_zero_dimension_check();
        std::cout << "All GEMM tests passed.\n";
        return EXIT_SUCCESS;
    } catch (const std::exception& error) {
        std::cerr << "Test failure: " << error.what() << '\n';
        return EXIT_FAILURE;
    }
}
