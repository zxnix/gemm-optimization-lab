#pragma once

#include "gemm/verification.hpp"
#include "kernel_registry.hpp"

#include <cstddef>
#include <string>
#include <vector>

namespace gemm::benchmark {

/** @brief 一个 GEMM 实验用例的逻辑形状：A(M×K) · B(K×N) = C(M×N)。 */
struct Shape {
    std::size_t m;
    std::size_t n;
    std::size_t k;
};

/** @brief 一次正式 kernel 测量及其 packing + kernel 派生指标。 */
struct RunResult {
    int run;
    double milliseconds;
    double gflops;
    double packing_milliseconds;
    double one_shot_milliseconds;
    double one_shot_gflops;
};

/** @brief 一个矩阵形状的全部测量结果与计时外数值验证结果。 */
struct CaseResult {
    Shape shape;
    std::vector<RunResult> runs;
    VerificationResult verification;
    bool verification_performed = true;
};

/** @brief benchmark CLI 解析后的完整实验配置。 */
struct Options {
    int repeats = 7;
    std::vector<Shape> shapes{
        {256, 256, 256},
        {512, 512, 512},
        {1024, 1024, 1024},
    };
    std::string csv_path;
    KernelKind kernel = KernelKind::Naive;
    std::size_t block_size = 32;
    std::size_t thread_count = 1;
    bool verify_results = true;
};

}  // namespace gemm::benchmark
