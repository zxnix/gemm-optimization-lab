#include "benchmark_output.hpp"

#include "benchmark_statistics.hpp"
#include "kernel_registry.hpp"

#include <ctime>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <ostream>
#include <sstream>
#include <stdexcept>

namespace gemm::benchmark {
namespace {

std::string utc_timestamp() {
    const std::time_t now = std::time(nullptr);
    std::tm value{};
    gmtime_r(&now, &value);
    std::ostringstream output;
    output << std::put_time(&value, "%Y-%m-%dT%H:%M:%SZ");
    return output.str();
}

}  // namespace

void ConsoleReporter::print_benchmark_header(const Options& options) {
    const KernelDescriptor& descriptor =
        kernel_descriptor(options.kernel);
    const std::size_t reported_block_size =
        descriptor.uses_block_size ? options.block_size : 0;
    output_
        << "GEMM Optimization Lab - FP32 GEMM benchmark\n"
        << "kernel=" << descriptor.name
        << ", block-size=" << reported_block_size
        << ", layout=row-major, loop-order=" << descriptor.loop_order
        << ", target-isa=" << descriptor.target_isa
        << ", microkernel=" << descriptor.microkernel
        << ", threads=" << options.thread_count
        << ", warm-up=1, repeats=" << options.repeats
        << ", optimization=" << GEMM_OPT_LEVEL << '\n';
}

void ConsoleReporter::print_case_header(const Shape& shape) {
    output_ << "\nM=" << shape.m
            << ", N=" << shape.n
            << ", K=" << shape.k << '\n';
}

void ConsoleReporter::print_packing_header() {
    output_ << "  packing (separate from kernel time):\n";
}

void ConsoleReporter::print_packing_run(int run, double milliseconds) {
    output_ << "    run " << run << ": "
            << std::fixed << std::setprecision(3)
            << milliseconds << " ms\n";
}

void ConsoleReporter::print_packing_summary(double mean_ms,
                                            double median_ms) {
    output_ << "    mean:   " << mean_ms << " ms\n"
            << "    median: " << median_ms << " ms\n";
}

void ConsoleReporter::print_kernel_run(const RunResult& result) {
    output_ << "  run " << result.run << ": "
            << std::fixed << std::setprecision(3)
            << result.milliseconds << " ms, "
            << result.gflops << " GFLOP/s\n";
}

void ConsoleReporter::print_kernel_summary(const Shape& shape,
                                           double mean_ms,
                                           double median_ms) {
    output_ << "  mean:   " << mean_ms << " ms, "
            << calculate_gflops(shape, mean_ms) << " GFLOP/s\n"
            << "  median: " << median_ms << " ms, "
            << calculate_gflops(shape, median_ms) << " GFLOP/s\n";
}

void ConsoleReporter::print_one_shot_summary(const Shape& shape,
                                             double median_ms) {
    output_ << "  one-shot median (packing + kernel): "
            << median_ms << " ms, "
            << calculate_gflops(shape, median_ms)
            << " effective GFLOP/s\n";
}

void ConsoleReporter::print_verification(
    const VerificationResult& verification) {
    output_ << "  verify: "
            << (verification.passed ? "PASS" : "FAIL")
            << ", max_abs_error=" << std::scientific
            << verification.max_absolute_error
            << ", max_rel_error=" << verification.max_relative_error
            << ", failures=" << verification.failure_count
            << std::defaultfloat << '\n';
}

void ConsoleReporter::print_verification_skipped() {
    output_ << "  verify: SKIPPED (counter workload only)\n";
}

void ConsoleReporter::print_csv_written(const std::string& path) {
    output_ << "\nCSV written to " << path << '\n';
}

void write_csv(const std::string& path,
               const std::vector<CaseResult>& cases,
               const Options& options) {
    const std::filesystem::path output_path(path);
    if (output_path.has_parent_path()) {
        std::filesystem::create_directories(
            output_path.parent_path());
    }
    std::ofstream output(output_path);
    if (!output) {
        throw std::runtime_error(
            "cannot open CSV output: " + path);
    }

    output
        << "timestamp_utc,compiler,compiler_version,build_type,kernel,"
           "target_isa,microkernel,block_size,threads,optimization_level,"
           "m,n,k,run,time_ms,gflops,packing_time_ms,one_shot_time_ms,"
           "one_shot_gflops,verified,max_abs_error,max_rel_error\n";
    const std::string timestamp = utc_timestamp();
    const KernelDescriptor& descriptor =
        kernel_descriptor(options.kernel);
    const std::size_t reported_block_size =
        descriptor.uses_block_size ? options.block_size : 0;
    output << std::setprecision(12);

    for (const CaseResult& item : cases) {
        for (const RunResult& run : item.runs) {
            output
                << timestamp << ','
                << GEMM_COMPILER_ID << ','
                << GEMM_COMPILER_VERSION << ','
                << GEMM_BUILD_TYPE << ','
                << descriptor.name << ','
                << descriptor.target_isa << ','
                << descriptor.microkernel << ','
                << reported_block_size << ','
                << options.thread_count << ','
                << GEMM_OPT_LEVEL << ','
                << item.shape.m << ','
                << item.shape.n << ','
                << item.shape.k << ','
                << run.run << ','
                << run.milliseconds << ','
                << run.gflops << ','
                << run.packing_milliseconds << ','
                << run.one_shot_milliseconds << ','
                << run.one_shot_gflops << ','
                << (item.verification.passed ? "true" : "false") << ','
                << item.verification.max_absolute_error << ','
                << item.verification.max_relative_error << '\n';
        }
    }
}

}  // namespace gemm::benchmark
