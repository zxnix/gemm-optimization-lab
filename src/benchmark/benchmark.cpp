#include "gemm/gemm.hpp"
#include "gemm/verification.hpp"
#include "kernel_registry.hpp"

#include <algorithm>
#include <chrono>
#include <cstdlib>
#include <ctime>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <limits>
#include <numeric>
#include <optional>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

namespace {

using Clock = std::chrono::steady_clock;

struct Shape { std::size_t m; std::size_t n; std::size_t k; };
struct RunResult { int run; double milliseconds; double gflops; };
struct CaseResult {
    Shape shape;
    std::vector<RunResult> runs;
    std::vector<double> packing_times;
    gemm::VerificationResult verification;
    bool verification_performed = true;
};
struct Options {
    int repeats = 7;
    std::vector<Shape> shapes{{256, 256, 256}, {512, 512, 512}, {1024, 1024, 1024}};
    std::string csv_path;
    gemm::benchmark::KernelKind kernel =
        gemm::benchmark::KernelKind::Naive;
    std::size_t block_size = 32;
    std::size_t thread_count = 1;
    bool verify_results = true;
};

std::size_t parse_positive_size(const std::string& text, const char* name) {
    std::size_t parsed = 0;
    const unsigned long long value = std::stoull(text, &parsed);
    if (parsed != text.size() || value == 0) {
        throw std::invalid_argument(std::string(name) + " must be a positive integer");
    }
    return static_cast<std::size_t>(value);
}

std::vector<Shape> parse_square_sizes(const std::string& text) {
    std::vector<Shape> shapes;
    std::stringstream stream(text);
    std::string token;
    while (std::getline(stream, token, ',')) {
        const std::size_t size = parse_positive_size(token, "matrix size");
        shapes.push_back({size, size, size});
    }
    if (shapes.empty()) throw std::invalid_argument("--sizes requires at least one size");
    return shapes;
}

Options parse_options(int argc, char** argv) {
    Options options;
    bool custom_sizes = false;
    bool rectangular = false;
    std::size_t m = 0, n = 0, k = 0;
    for (int index = 1; index < argc; ++index) {
        const std::string argument = argv[index];
        auto require_value = [&]() -> std::string {
            if (index + 1 >= argc) throw std::invalid_argument("missing value for " + argument);
            return argv[++index];
        };
        if (argument == "--repeats") {
            const std::size_t repeats = parse_positive_size(require_value(), "repeats");
            if (repeats > static_cast<std::size_t>(std::numeric_limits<int>::max())) {
                throw std::invalid_argument("repeats is too large");
            }
            options.repeats = static_cast<int>(repeats);
        } else if (argument == "--sizes") {
            options.shapes = parse_square_sizes(require_value());
            custom_sizes = true;
        } else if (argument == "--m") { m = parse_positive_size(require_value(), "M"); rectangular = true;
        } else if (argument == "--n") { n = parse_positive_size(require_value(), "N"); rectangular = true;
        } else if (argument == "--k") { k = parse_positive_size(require_value(), "K"); rectangular = true;
        } else if (argument == "--csv") {
            options.csv_path = require_value();
        } else if (argument == "--kernel") {
            options.kernel =
                gemm::benchmark::parse_kernel_kind(require_value());
        } else if (argument == "--block-size") {
            options.block_size = parse_positive_size(require_value(), "block-size");
        } else if (argument == "--threads") {
            options.thread_count = parse_positive_size(require_value(), "threads");
        } else if (argument == "--skip-verification") {
            options.verify_results = false;
        } else if (argument == "--help") {
            std::cout
                << "Usage: gemm_benchmark [--repeats R] [--sizes S1,S2,...] "
                   "[--m M --n N --k K] [--kernel "
                << gemm::benchmark::kernel_choices("|")
                << "] [--block-size B] [--threads T] [--csv PATH] "
                   "[--skip-verification]\n";
            std::exit(EXIT_SUCCESS);
        } else {
            throw std::invalid_argument("unknown argument: " + argument);
        }
    }
    if (custom_sizes && rectangular) throw std::invalid_argument("--sizes cannot be combined with --m/--n/--k");
    if (rectangular) {
        if (m == 0 || n == 0 || k == 0) throw std::invalid_argument("--m, --n, and --k must be provided together");
        options.shapes = {{m, n, k}};
    }
    const gemm::benchmark::KernelDescriptor& descriptor =
        gemm::benchmark::kernel_descriptor(options.kernel);
    if (!descriptor.supports_threads && options.thread_count != 1) {
        throw std::invalid_argument(
            "--threads greater than 1 requires --kernel avx2-mt");
    }
    if (!options.verify_results && !options.csv_path.empty()) {
        throw std::invalid_argument(
            "--skip-verification cannot be combined with --csv");
    }
    return options;
}

double median(std::vector<double> values) {
    std::sort(values.begin(), values.end());
    const std::size_t middle = values.size() / 2;
    return values.size() % 2 == 1 ? values[middle] : (values[middle - 1] + values[middle]) / 2.0;
}

double calculate_gflops(const Shape& shape, double milliseconds) {
    // HPC 约定一次乘法和一次加法各计一次，因此 GEMM 约为 2MNK FLOPs。
    const double operations = 2.0 * static_cast<double>(shape.m) *
                              static_cast<double>(shape.n) * static_cast<double>(shape.k);
    return operations / (milliseconds * 1.0e6);
}

std::string utc_timestamp() {
    const std::time_t now = std::time(nullptr);
    std::tm value{};
    gmtime_r(&now, &value);
    std::ostringstream output;
    output << std::put_time(&value, "%Y-%m-%dT%H:%M:%SZ");
    return output.str();
}

CaseResult benchmark_shape(const Shape& shape, const Options& options) {
    gemm::Matrix a(shape.m, shape.k), b(shape.k, shape.n), c(shape.m, shape.n);
    const std::uint32_t seed_offset = static_cast<std::uint32_t>((shape.m + shape.n + shape.k) & 0xffffffffU);
    gemm::fill_random(a, 20260911U + seed_offset);
    gemm::fill_random(b, 20261009U + seed_offset);

    std::cout << "\nM=" << shape.m << ", N=" << shape.n << ", K=" << shape.k << '\n';
    std::optional<gemm::PackedB> packed_b;
    std::vector<double> packing_times;
    const gemm::benchmark::KernelDescriptor& descriptor =
        gemm::benchmark::kernel_descriptor(options.kernel);
    if (descriptor.uses_packed_b) {
        // workspace 分配在计时外；这里只测量 row-major B 到预分配 packed buffer 的转换。
        packed_b.emplace(shape.k, shape.n, options.block_size);
        gemm::pack_b(b, *packed_b);
        packing_times.reserve(static_cast<std::size_t>(options.repeats));
        std::cout << "  packing (separate from kernel time):\n";
        for (int run = 1; run <= options.repeats; ++run) {
            const auto start = Clock::now();
            gemm::pack_b(b, *packed_b);
            const auto stop = Clock::now();
            const double ms =
                std::chrono::duration<double, std::milli>(stop - start).count();
            packing_times.push_back(ms);
            std::cout << "    run " << run << ": " << std::fixed << std::setprecision(3)
                      << ms << " ms\n";
        }
        const double packing_mean =
            std::accumulate(packing_times.begin(), packing_times.end(), 0.0) /
            packing_times.size();
        std::cout << "    mean:   " << packing_mean << " ms\n"
                  << "    median: " << median(packing_times) << " ms\n";
    }

    // warm-up 不计时，降低首次访存和 CPU 状态变化造成的特殊性。
    gemm::benchmark::execute_kernel(
        options.kernel, a, b, c, packed_b ? &*packed_b : nullptr,
        options.block_size, options.thread_count);

    CaseResult result{shape, {}, packing_times, {}, options.verify_results};
    result.runs.reserve(static_cast<std::size_t>(options.repeats));
    for (int run = 1; run <= options.repeats; ++run) {
        // 计时边界只包围 kernel；分配、初始化、输出和验证均在边界外。
        const auto start = Clock::now();
        gemm::benchmark::execute_kernel(
            options.kernel, a, b, c, packed_b ? &*packed_b : nullptr,
            options.block_size, options.thread_count);
        const auto stop = Clock::now();
        const double ms = std::chrono::duration<double, std::milli>(stop - start).count();
        result.runs.push_back({run, ms, calculate_gflops(shape, ms)});
        std::cout << "  run " << run << ": " << std::fixed << std::setprecision(3)
                  << ms << " ms, " << result.runs.back().gflops << " GFLOP/s\n";
    }

    std::vector<double> times;
    for (const RunResult& run : result.runs) times.push_back(run.milliseconds);
    const double mean_ms = std::accumulate(times.begin(), times.end(), 0.0) / times.size();
    const double median_ms = median(times);
    std::cout << "  mean:   " << mean_ms << " ms, " << calculate_gflops(shape, mean_ms) << " GFLOP/s\n"
              << "  median: " << median_ms << " ms, " << calculate_gflops(shape, median_ms) << " GFLOP/s\n";
    if (!packing_times.empty()) {
        std::vector<double> one_shot_times;
        one_shot_times.reserve(times.size());
        for (std::size_t index = 0; index < times.size(); ++index) {
            one_shot_times.push_back(times[index] + packing_times[index]);
        }
        const double one_shot_median = median(one_shot_times);
        std::cout << "  one-shot median (packing + kernel): " << one_shot_median
                  << " ms, " << calculate_gflops(shape, one_shot_median)
                  << " effective GFLOP/s\n";
    }

    if (options.verify_results) {
        // FP64 reference 也是 O(MNK)，必须在计时外执行。
        result.verification = gemm::verify_gemm(a, b, c);
        std::cout << "  verify: " << (result.verification.passed ? "PASS" : "FAIL")
                  << ", max_abs_error=" << std::scientific
                  << result.verification.max_absolute_error
                  << ", max_rel_error=" << result.verification.max_relative_error
                  << ", failures=" << result.verification.failure_count
                  << std::defaultfloat << '\n';
    } else {
        // 仅供外部硬件计数器 workload 使用；正式 benchmark 和 CSV 禁止跳过验证。
        std::cout << "  verify: SKIPPED (counter workload only)\n";
    }
    return result;
}

void write_csv(const std::string& path,
               const std::vector<CaseResult>& cases,
               const Options& options) {
    const std::filesystem::path output_path(path);
    if (output_path.has_parent_path()) std::filesystem::create_directories(output_path.parent_path());
    std::ofstream output(output_path);
    if (!output) throw std::runtime_error("cannot open CSV output: " + path);
    output << "timestamp_utc,compiler,compiler_version,build_type,kernel,target_isa,microkernel,block_size,threads,optimization_level,m,n,k,run,time_ms,gflops,packing_time_ms,one_shot_time_ms,one_shot_gflops,verified,max_abs_error,max_rel_error\n";
    const std::string timestamp = utc_timestamp();
    const gemm::benchmark::KernelDescriptor& descriptor =
        gemm::benchmark::kernel_descriptor(options.kernel);
    const std::size_t reported_block_size =
        descriptor.uses_block_size ? options.block_size : 0;
    output << std::setprecision(12);
    for (const CaseResult& item : cases) {
        for (const RunResult& run : item.runs) {
            const double packing_ms = item.packing_times.empty()
                ? 0.0
                : item.packing_times[static_cast<std::size_t>(run.run - 1)];
            const double one_shot_ms = run.milliseconds + packing_ms;
            output << timestamp << ',' << GEMM_COMPILER_ID << ',' << GEMM_COMPILER_VERSION << ','
                   << GEMM_BUILD_TYPE << ',' << descriptor.name << ','
                   << descriptor.target_isa << ',' << descriptor.microkernel << ','
                   << reported_block_size << ','
                   << options.thread_count << ',' << GEMM_OPT_LEVEL << ','
                   << item.shape.m << ',' << item.shape.n << ',' << item.shape.k
                   << ',' << run.run << ',' << run.milliseconds << ',' << run.gflops << ','
                   << packing_ms << ',' << one_shot_ms << ','
                   << calculate_gflops(item.shape, one_shot_ms) << ','
                   << (item.verification.passed ? "true" : "false") << ','
                   << item.verification.max_absolute_error << ',' << item.verification.max_relative_error << '\n';
        }
    }
    std::cout << "\nCSV written to " << path << '\n';
}

}  // namespace

int main(int argc, char** argv) {
    try {
        const Options options = parse_options(argc, argv);
        const gemm::benchmark::KernelDescriptor& descriptor =
            gemm::benchmark::kernel_descriptor(options.kernel);
        const std::size_t reported_block_size =
            descriptor.uses_block_size ? options.block_size : 0;
        std::cout << "GEMM Optimization Lab - FP32 GEMM benchmark\n"
                  << "kernel=" << descriptor.name
                  << ", block-size=" << reported_block_size
                  << ", layout=row-major, loop-order=" << descriptor.loop_order
                  << ", target-isa=" << descriptor.target_isa
                  << ", microkernel=" << descriptor.microkernel
                  << ", threads=" << options.thread_count
                  << ", warm-up=1, repeats=" << options.repeats
                  << ", optimization=" << GEMM_OPT_LEVEL << '\n';
        std::vector<CaseResult> results;
        bool all_passed = true;
        for (const Shape& shape : options.shapes) {
            results.push_back(benchmark_shape(shape, options));
            if (results.back().verification_performed) {
                all_passed = results.back().verification.passed && all_passed;
            }
        }
        if (!options.csv_path.empty()) write_csv(options.csv_path, results, options);
        return all_passed ? EXIT_SUCCESS : EXIT_FAILURE;
    } catch (const std::exception& error) {
        std::cerr << "error: " << error.what() << '\n';
        return EXIT_FAILURE;
    }
}
