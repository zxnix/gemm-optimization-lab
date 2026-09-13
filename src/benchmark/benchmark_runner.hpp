#pragma once

#include "benchmark_types.hpp"

namespace gemm::benchmark {

class ConsoleReporter;

/** @brief 执行一个 shape 的分配、初始化、warm-up、正式测量和验证。
 *
 * 只有 execute_kernel() 调用位于正式 kernel 计时区间内。输出仍发生在相邻的
 * 两次测量之间，以保持 Phase 1 benchmark 的运行协议。
 */
[[nodiscard]] CaseResult benchmark_shape(
    const Shape& shape,
    const Options& options,
    ConsoleReporter& reporter);

}  // namespace gemm::benchmark
