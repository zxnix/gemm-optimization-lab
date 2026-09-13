#pragma once

#include "benchmark_types.hpp"

#include <iosfwd>

namespace gemm::benchmark {

/** @brief CLI 解析结果；help_requested 为真时不执行 benchmark。 */
struct ParsedOptions {
    Options options;
    bool help_requested = false;
};

/** @brief 解析并验证 benchmark 命令行，不执行计算或输出。
 * @throws std::invalid_argument 参数缺失、冲突或取值非法时抛出。 */
[[nodiscard]] ParsedOptions parse_options(int argc, char* const argv[]);

/** @brief 输出稳定的 benchmark CLI 使用说明。 */
void print_usage(std::ostream& output);

}  // namespace gemm::benchmark
