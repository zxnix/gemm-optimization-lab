#include "benchmark_output.hpp"
#include "benchmark_statistics.hpp"

#include <cmath>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

namespace {

using gemm::benchmark::CaseResult;
using gemm::benchmark::ConsoleReporter;
using gemm::benchmark::KernelKind;
using gemm::benchmark::Options;
using gemm::benchmark::RunResult;
using gemm::benchmark::Shape;

void require(bool condition, const char* message) {
    if (!condition) {
        throw std::runtime_error(message);
    }
}

void require_close(double actual,
                   double expected,
                   double tolerance,
                   const char* message) {
    require(std::abs(actual - expected) <= tolerance, message);
}

std::vector<std::string> split_csv_row(const std::string& row) {
    std::vector<std::string> fields;
    std::stringstream stream(row);
    std::string field;
    while (std::getline(stream, field, ',')) {
        fields.push_back(field);
    }
    return fields;
}

void test_statistics() {
    require_close(
        gemm::benchmark::median({7.0, 1.0, 3.0}),
        3.0,
        0.0,
        "odd median is wrong");
    require_close(
        gemm::benchmark::median({8.0, 2.0, 4.0, 6.0}),
        5.0,
        0.0,
        "even median is wrong");
    require_close(
        gemm::benchmark::calculate_gflops({1000, 1000, 1000}, 2.0),
        1000.0,
        1.0e-12,
        "GFLOP/s calculation is wrong");
}

void test_console_reporter() {
    std::ostringstream output;
    ConsoleReporter reporter(output);
    const Shape shape{1000, 1000, 1000};
    const RunResult run{1, 2.0, 1000.0, 0.25, 2.25, 888.0};
    gemm::VerificationResult verification;
    verification.passed = true;
    verification.max_absolute_error = 1.25e-4;
    verification.max_relative_error = 2.5e-4;

    reporter.print_case_header(shape);
    reporter.print_packing_header();
    reporter.print_packing_run(1, 0.25);
    reporter.print_packing_summary(0.375, 0.25);
    reporter.print_kernel_run(run);
    reporter.print_kernel_summary(shape, 2.0, 4.0);
    reporter.print_one_shot_summary(shape, 5.0);
    reporter.print_verification(verification);
    reporter.print_verification_skipped();
    reporter.print_csv_written("result.csv");

    require(
        output.str() ==
            "\nM=1000, N=1000, K=1000\n"
            "  packing (separate from kernel time):\n"
            "    run 1: 0.250 ms\n"
            "    mean:   0.375 ms\n"
            "    median: 0.250 ms\n"
            "  run 1: 2.000 ms, 1000.000 GFLOP/s\n"
            "  mean:   2.000 ms, 1000.000 GFLOP/s\n"
            "  median: 4.000 ms, 500.000 GFLOP/s\n"
            "  one-shot median (packing + kernel): "
            "5.000 ms, 400.000 effective GFLOP/s\n"
            "  verify: PASS, max_abs_error=1.250e-04, "
            "max_rel_error=2.500e-04, failures=0\n"
            "  verify: SKIPPED (counter workload only)\n"
            "\nCSV written to result.csv\n",
        "console report format changed");
}

void test_benchmark_header() {
    Options options;
    options.kernel = KernelKind::Micro;
    options.block_size = 64;
    options.repeats = 3;

    std::ostringstream output;
    ConsoleReporter(output).print_benchmark_header(options);
    const std::string text = output.str();
    require(
        text.find(
            "kernel=micro, block-size=64, layout=row-major, "
            "loop-order=packed-register-blocked, target-isa=generic, "
            "microkernel=4x8, threads=1, warm-up=1, repeats=3, "
            "optimization=") != std::string::npos,
        "benchmark header metadata changed");
    require(!text.empty() && text.back() == '\n',
            "benchmark header lost its final newline");
}

void test_csv_schema(const std::filesystem::path& path) {
    Options options;
    options.kernel = KernelKind::Packed;
    options.block_size = 64;

    CaseResult item;
    item.shape = {2, 3, 4};
    item.runs.push_back({1, 1.25, 3.4, 0.25, 1.5, 2.3});
    item.verification.passed = true;
    item.verification.max_absolute_error = 0.001;
    item.verification.max_relative_error = 0.002;

    gemm::benchmark::write_csv(
        path.string(), std::vector<CaseResult>{item}, options);

    std::ifstream input(path);
    require(static_cast<bool>(input), "test CSV could not be opened");
    std::string header;
    std::string row;
    std::getline(input, header);
    std::getline(input, row);
    input.close();
    std::filesystem::remove(path);

    require(
        header ==
            "timestamp_utc,compiler,compiler_version,build_type,kernel,"
            "target_isa,microkernel,block_size,threads,optimization_level,"
            "m,n,k,run,time_ms,gflops,packing_time_ms,one_shot_time_ms,"
            "one_shot_gflops,verified,max_abs_error,max_rel_error",
        "CSV header changed");

    const std::vector<std::string> fields = split_csv_row(row);
    require(fields.size() == 22, "CSV field count changed");
    require(fields[4] == "packed", "CSV kernel field is wrong");
    require(fields[5] == "generic", "CSV ISA field is wrong");
    require(fields[6] == "none", "CSV microkernel field is wrong");
    require(fields[7] == "64", "CSV block size field is wrong");
    require(fields[8] == "1", "CSV thread field is wrong");
    require(fields[10] == "2" &&
                fields[11] == "3" &&
                fields[12] == "4",
            "CSV shape fields are wrong");
    require(fields[13] == "1", "CSV run field is wrong");
    require(fields[19] == "true", "CSV verification field is wrong");
    require(fields[20] == "0.001", "CSV absolute error field is wrong");
    require(fields[21] == "0.002", "CSV relative error field is wrong");
}

}  // namespace

int main(int argc, char** argv) {
    try {
        if (argc != 2) {
            throw std::invalid_argument(
                "expected one temporary CSV path");
        }
        test_statistics();
        test_console_reporter();
        test_benchmark_header();
        test_csv_schema(argv[1]);
        std::cout << "All benchmark component tests passed.\n";
        return EXIT_SUCCESS;
    } catch (const std::exception& error) {
        std::cerr << "Test failure: " << error.what() << '\n';
        return EXIT_FAILURE;
    }
}
