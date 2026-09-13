#pragma once

#include "benchmark_types.hpp"

#include <vector>

namespace gemm::benchmark {

/** @brief 计算非空样本集合的中位数。 */
[[nodiscard]] double median(std::vector<double> values);

/** @brief 按 2MNK FLOPs 约定计算一次 GEMM 的 GFLOP/s。 */
[[nodiscard]] double calculate_gflops(
    const Shape& shape,
    double milliseconds);

}  // namespace gemm::benchmark
