#include "benchmark_statistics.hpp"

#include <algorithm>

namespace gemm::benchmark {

double median(std::vector<double> values) {
    std::sort(values.begin(), values.end());
    const std::size_t middle = values.size() / 2;
    return values.size() % 2 == 1
        ? values[middle]
        : (values[middle - 1] + values[middle]) / 2.0;
}

double calculate_gflops(const Shape& shape, double milliseconds) {
    // HPC 约定一次乘法和一次加法各计一次，因此 GEMM 约为 2MNK FLOPs。
    const double operations =
        2.0 * static_cast<double>(shape.m) *
        static_cast<double>(shape.n) *
        static_cast<double>(shape.k);
    return operations / (milliseconds * 1.0e6);
}

}  // namespace gemm::benchmark
