#include "benchmark_options.hpp"

#include <cstdlib>
#include <iostream>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

namespace {

using gemm::benchmark::KernelKind;
using gemm::benchmark::ParsedOptions;
using gemm::benchmark::Shape;

void require(bool condition, const char* message) {
    if (!condition) {
        throw std::runtime_error(message);
    }
}

ParsedOptions parse(std::vector<std::string> arguments) {
    std::vector<char*> argv;
    argv.reserve(arguments.size());
    for (std::string& argument : arguments) {
        argv.push_back(argument.data());
    }
    return gemm::benchmark::parse_options(
        static_cast<int>(argv.size()), argv.data());
}

void require_shape(const Shape& shape,
                   std::size_t m,
                   std::size_t n,
                   std::size_t k) {
    require(
        shape.m == m && shape.n == n && shape.k == k,
        "parsed matrix shape is wrong");
}

void require_invalid(const std::vector<std::string>& arguments,
                     const std::string& expected_message) {
    try {
        (void)parse(arguments);
    } catch (const std::invalid_argument& error) {
        require(
            error.what() == expected_message,
            "invalid argument message changed");
        return;
    }
    throw std::runtime_error("invalid arguments were accepted");
}

void test_defaults() {
    const ParsedOptions parsed = parse({"gemm_benchmark"});
    const auto& options = parsed.options;
    require(!parsed.help_requested, "default parse requested help");
    require(options.repeats == 7, "default repeats changed");
    require(options.shapes.size() == 3, "default shape count changed");
    require_shape(options.shapes[0], 256, 256, 256);
    require_shape(options.shapes[1], 512, 512, 512);
    require_shape(options.shapes[2], 1024, 1024, 1024);
    require(options.kernel == KernelKind::Naive, "default kernel changed");
    require(options.block_size == 32, "default block size changed");
    require(options.thread_count == 1, "default thread count changed");
    require(options.verify_results, "verification default changed");
}

void test_custom_options() {
    const ParsedOptions square = parse({
        "gemm_benchmark",
        "--repeats", "3",
        "--sizes", "16,32",
        "--kernel", "avx2-mt",
        "--block-size", "64",
        "--threads", "4",
    });
    require(square.options.repeats == 3, "custom repeats were ignored");
    require(square.options.shapes.size() == 2, "square sizes were not parsed");
    require_shape(square.options.shapes[0], 16, 16, 16);
    require_shape(square.options.shapes[1], 32, 32, 32);
    require(
        square.options.kernel == KernelKind::Avx2Multithreaded,
        "custom kernel was not parsed");
    require(square.options.block_size == 64, "custom block size was ignored");
    require(square.options.thread_count == 4, "custom threads were ignored");

    const ParsedOptions rectangular = parse({
        "gemm_benchmark",
        "--m", "3",
        "--n", "5",
        "--k", "7",
        "--skip-verification",
    });
    require(
        rectangular.options.shapes.size() == 1,
        "rectangular shape count is wrong");
    require_shape(rectangular.options.shapes[0], 3, 5, 7);
    require(
        !rectangular.options.verify_results,
        "skip-verification was ignored");
}

void test_help_text() {
    const ParsedOptions parsed =
        parse({"gemm_benchmark", "--help", "--unknown"});
    require(parsed.help_requested, "--help was not recognized");

    std::ostringstream output;
    gemm::benchmark::print_usage(output);
    require(
        output.str() ==
            "Usage: gemm_benchmark [--repeats R] [--sizes S1,S2,...] "
            "[--m M --n N --k K] [--kernel "
            "naive|ikj|blocked|packed|micro|avx2|avx2-mt] "
            "[--block-size B] [--threads T] [--csv PATH] "
            "[--skip-verification]\n",
        "usage text changed");
}

void test_invalid_combinations() {
    require_invalid(
        {"gemm_benchmark", "--sizes", "16",
         "--m", "1", "--n", "1", "--k", "1"},
        "--sizes cannot be combined with --m/--n/--k");
    require_invalid(
        {"gemm_benchmark", "--m", "1"},
        "--m, --n, and --k must be provided together");
    require_invalid(
        {"gemm_benchmark", "--kernel", "naive", "--threads", "2"},
        "--threads greater than 1 requires --kernel avx2-mt");
    require_invalid(
        {"gemm_benchmark", "--skip-verification",
         "--csv", "result.csv"},
        "--skip-verification cannot be combined with --csv");
    require_invalid(
        {"gemm_benchmark", "--unknown"},
        "unknown argument: --unknown");
}

}  // namespace

int main() {
    try {
        test_defaults();
        test_custom_options();
        test_help_text();
        test_invalid_combinations();
        std::cout << "All benchmark option tests passed.\n";
        return EXIT_SUCCESS;
    } catch (const std::exception& error) {
        std::cerr << "Test failure: " << error.what() << '\n';
        return EXIT_FAILURE;
    }
}
