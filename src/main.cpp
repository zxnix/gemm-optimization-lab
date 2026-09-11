#include "gemm/gemm.hpp"
#include "gemm/verification.hpp"

#include <algorithm>
#include <chrono>
#include <cstdlib>
#include <exception>
#include <iomanip>
#include <iostream>
#include <numeric>
#include <stdexcept>
#include <string>
#include <vector>

namespace {

using Clock = std::chrono::steady_clock;

double median(std::vector<double> values) {
    std::sort(values.begin(), values.end());
    const std::size_t middle = values.size() / 2;
    if (values.size() % 2 == 1) {
        return values[middle];
    }
    return (values[middle - 1] + values[middle]) / 2.0;
}

double gflops(std::size_t m, std::size_t n, std::size_t k, double milliseconds) {
    const double operations = 2.0 * static_cast<double>(m) * static_cast<double>(n) *
                              static_cast<double>(k);
    return operations / (milliseconds * 1.0e6);
}

int parse_repeats(int argc, char** argv) {
    int repeats = 7;
    for (int index = 1; index < argc; ++index) {
        const std::string argument = argv[index];
        if (argument == "--repeats" && index + 1 < argc) {
            repeats = std::stoi(argv[++index]);
        } else if (argument == "--help") {
            std::cout << "Usage: gemm_benchmark [--repeats N]\n";
            std::exit(EXIT_SUCCESS);
        } else {
            throw std::invalid_argument("unknown or incomplete argument: " + argument);
        }
    }
    if (repeats <= 0) {
        throw std::invalid_argument("repeats must be positive");
    }
    return repeats;
}

bool benchmark_size(std::size_t size, int repeats) {
    gemm::Matrix a(size, size);
    gemm::Matrix b(size, size);
    gemm::Matrix c(size, size);
    gemm::fill_random(a, 20260911U + static_cast<std::uint32_t>(size));
    gemm::fill_random(b, 20261009U + static_cast<std::uint32_t>(size));

    std::cout << "\nN=" << size << ", FLOPs="
              << 2.0 * static_cast<double>(size) * static_cast<double>(size) *
                     static_cast<double>(size)
              << '\n';

    gemm::gemm_naive(a, b, c);  // One untimed warm-up.

    std::vector<double> milliseconds;
    milliseconds.reserve(static_cast<std::size_t>(repeats));
    for (int run = 0; run < repeats; ++run) {
        const auto start = Clock::now();
        gemm::gemm_naive(a, b, c);
        const auto stop = Clock::now();
        const double elapsed =
            std::chrono::duration<double, std::milli>(stop - start).count();
        milliseconds.push_back(elapsed);
        std::cout << "  run " << (run + 1) << ": " << std::fixed << std::setprecision(3)
                  << elapsed << " ms, " << std::setprecision(3)
                  << gflops(size, size, size, elapsed) << " GFLOP/s\n";
    }

    const double mean_ms =
        std::accumulate(milliseconds.begin(), milliseconds.end(), 0.0) /
        static_cast<double>(milliseconds.size());
    const double median_ms = median(milliseconds);
    std::cout << "  mean:   " << mean_ms << " ms, "
              << gflops(size, size, size, mean_ms) << " GFLOP/s\n"
              << "  median: " << median_ms << " ms, "
              << gflops(size, size, size, median_ms) << " GFLOP/s\n";

    const gemm::VerificationResult verification = gemm::verify_gemm(a, b, c);
    std::cout << "  verify: " << (verification.passed ? "PASS" : "FAIL")
              << ", max_abs_error=" << std::scientific << verification.max_absolute_error
              << ", max_rel_error=" << verification.max_relative_error
              << ", failures=" << verification.failure_count << std::defaultfloat << '\n';
    if (!verification.passed) {
        std::cout << "  worst element: (" << verification.worst_row << ", "
                  << verification.worst_col << "), computed="
                  << verification.computed_at_worst << ", reference="
                  << verification.reference_at_worst << '\n';
    }
    return verification.passed;
}

}  // namespace

int main(int argc, char** argv) {
    try {
        const int repeats = parse_repeats(argc, argv);
        std::cout << "GEMM Optimization Lab - FP32 naive baseline\n"
                  << "layout=row-major, loop-order=i-j-k, threads=1, warm-up=1, repeats="
                  << repeats << '\n';

        bool all_passed = true;
        for (const std::size_t size : {256U, 512U, 1024U}) {
            all_passed = benchmark_size(size, repeats) && all_passed;
        }
        return all_passed ? EXIT_SUCCESS : EXIT_FAILURE;
    } catch (const std::exception& error) {
        std::cerr << "error: " << error.what() << '\n';
        return EXIT_FAILURE;
    }
}
