#include "benchmark_runner.hpp"

#include "benchmark_output.hpp"
#include "benchmark_statistics.hpp"
#include "gemm/gemm.hpp"
#include "gemm/verification.hpp"
#include "kernel_registry.hpp"

#include <chrono>
#include <cstdint>
#include <numeric>
#include <optional>
#include <vector>

namespace gemm::benchmark {
namespace {

using Clock = std::chrono::steady_clock;

}  // namespace

CaseResult benchmark_shape(const Shape& shape,
                           const Options& options,
                           ConsoleReporter& reporter) {
    Matrix a(shape.m, shape.k);
    Matrix b(shape.k, shape.n);
    Matrix c(shape.m, shape.n);
    const std::uint32_t seed_offset =
        static_cast<std::uint32_t>(
            (shape.m + shape.n + shape.k) & 0xffffffffU);
    fill_random(a, 20260911U + seed_offset);
    fill_random(b, 20261009U + seed_offset);

    reporter.print_case_header(shape);
    std::optional<PackedB> packed_b;
    std::vector<double> packing_times;
    const KernelDescriptor& descriptor =
        kernel_descriptor(options.kernel);
    if (descriptor.uses_packed_b) {
        // workspace 分配在计时外；这里只测量 row-major B 到预分配 buffer 的转换。
        packed_b.emplace(shape.k, shape.n, options.block_size);
        pack_b(b, *packed_b);
        packing_times.reserve(
            static_cast<std::size_t>(options.repeats));
        reporter.print_packing_header();
        for (int run = 1; run <= options.repeats; ++run) {
            const auto start = Clock::now();
            pack_b(b, *packed_b);
            const auto stop = Clock::now();
            const double milliseconds =
                std::chrono::duration<double, std::milli>(
                    stop - start).count();
            packing_times.push_back(milliseconds);
            reporter.print_packing_run(run, milliseconds);
        }
        const double packing_mean =
            std::accumulate(
                packing_times.begin(), packing_times.end(), 0.0) /
            packing_times.size();
        reporter.print_packing_summary(
            packing_mean, median(packing_times));
    }

    // warm-up 不计时，降低首次访存和 CPU 状态变化造成的特殊性。
    execute_kernel(
        options.kernel, a, b, c,
        packed_b ? &*packed_b : nullptr,
        options.block_size, options.thread_count);

    CaseResult result{
        shape, {}, {}, options.verify_results};
    result.runs.reserve(
        static_cast<std::size_t>(options.repeats));
    std::vector<double> kernel_times;
    kernel_times.reserve(
        static_cast<std::size_t>(options.repeats));
    std::vector<double> one_shot_times;
    one_shot_times.reserve(
        static_cast<std::size_t>(options.repeats));

    for (int run = 1; run <= options.repeats; ++run) {
        // 计时边界只包围 kernel；分配、初始化、输出和验证均在边界外。
        const auto start = Clock::now();
        execute_kernel(
            options.kernel, a, b, c,
            packed_b ? &*packed_b : nullptr,
            options.block_size, options.thread_count);
        const auto stop = Clock::now();
        const double milliseconds =
            std::chrono::duration<double, std::milli>(
                stop - start).count();
        const std::size_t result_index =
            static_cast<std::size_t>(run - 1);
        const double packing_ms = packing_times.empty()
            ? 0.0
            : packing_times[result_index];
        const double one_shot_ms = milliseconds + packing_ms;
        result.runs.push_back({
            run,
            milliseconds,
            calculate_gflops(shape, milliseconds),
            packing_ms,
            one_shot_ms,
            calculate_gflops(shape, one_shot_ms),
        });
        kernel_times.push_back(milliseconds);
        one_shot_times.push_back(one_shot_ms);
        reporter.print_kernel_run(result.runs.back());
    }

    const double mean_ms =
        std::accumulate(
            kernel_times.begin(), kernel_times.end(), 0.0) /
        kernel_times.size();
    const double median_ms = median(kernel_times);
    reporter.print_kernel_summary(shape, mean_ms, median_ms);
    if (!packing_times.empty()) {
        reporter.print_one_shot_summary(
            shape, median(one_shot_times));
    }

    if (options.verify_results) {
        // FP64 reference 也是 O(MNK)，必须在计时外执行。
        result.verification = verify_gemm(a, b, c);
        reporter.print_verification(result.verification);
    } else {
        // 仅供外部计数器 workload；正式 benchmark 和 CSV 禁止跳过验证。
        reporter.print_verification_skipped();
    }
    return result;
}

}  // namespace gemm::benchmark
