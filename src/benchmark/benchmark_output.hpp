#pragma once

#include "benchmark_types.hpp"

#include <iosfwd>
#include <string>
#include <vector>

namespace gemm::benchmark {

/** @brief 保持 benchmark 控制台输出格式的集中式报告器。 */
class ConsoleReporter {
public:
    explicit ConsoleReporter(std::ostream& output) : output_(output) {}

    void print_benchmark_header(const Options& options);
    void print_case_header(const Shape& shape);
    void print_packing_header();
    void print_packing_run(int run, double milliseconds);
    void print_packing_summary(double mean_ms, double median_ms);
    void print_kernel_run(const RunResult& result);
    void print_kernel_summary(const Shape& shape,
                              double mean_ms,
                              double median_ms);
    void print_one_shot_summary(const Shape& shape, double median_ms);
    void print_verification(const VerificationResult& verification);
    void print_verification_skipped();
    void print_csv_written(const std::string& path);

private:
    std::ostream& output_;
};

/** @brief 将全部正式运行写入既有稳定 CSV schema。 */
void write_csv(const std::string& path,
               const std::vector<CaseResult>& cases,
               const Options& options);

}  // namespace gemm::benchmark
