#include "gemm/gemm.hpp"
#include "gemm/verification.hpp"

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
    gemm::VerificationResult verification;
};
struct Options {
    int repeats = 7;
    std::vector<Shape> shapes{{256, 256, 256}, {512, 512, 512}, {1024, 1024, 1024}};
    std::string csv_path;
    std::string kernel = "naive";
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
            options.kernel = require_value();
            if (options.kernel != "naive" && options.kernel != "ikj") {
                throw std::invalid_argument("--kernel must be naive or ikj");
            }
        } else if (argument == "--help") {
            std::cout << "Usage: gemm_benchmark [--repeats R] [--sizes S1,S2,...] "
                         "[--m M --n N --k K] [--kernel naive|ikj] [--csv PATH]\n";
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

using GemmKernel = void (*)(const gemm::Matrix&, const gemm::Matrix&, gemm::Matrix&);

GemmKernel select_kernel(const std::string& name) {
    if (name == "naive") return gemm::gemm_naive;
    if (name == "ikj") return gemm::gemm_ikj;
    throw std::invalid_argument("unsupported kernel: " + name);
}

CaseResult benchmark_shape(const Shape& shape,
                           int repeats,
                           const std::string& kernel_name,
                           GemmKernel kernel) {
    gemm::Matrix a(shape.m, shape.k), b(shape.k, shape.n), c(shape.m, shape.n);
    const std::uint32_t seed_offset = static_cast<std::uint32_t>((shape.m + shape.n + shape.k) & 0xffffffffU);
    gemm::fill_random(a, 20260911U + seed_offset);
    gemm::fill_random(b, 20261009U + seed_offset);

    std::cout << "\nM=" << shape.m << ", N=" << shape.n << ", K=" << shape.k << '\n';
    // warm-up 不计时，降低首次访存和 CPU 状态变化造成的特殊性。
    kernel(a, b, c);

    CaseResult result{shape, {}, {}};
    result.runs.reserve(static_cast<std::size_t>(repeats));
    for (int run = 1; run <= repeats; ++run) {
        // 计时边界只包围 kernel；分配、初始化、输出和验证均在边界外。
        const auto start = Clock::now();
        kernel(a, b, c);
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

    // FP64 reference 也是 O(MNK)，必须在计时外执行。
    result.verification = gemm::verify_gemm(a, b, c);
    std::cout << "  verify: " << (result.verification.passed ? "PASS" : "FAIL")
              << ", max_abs_error=" << std::scientific << result.verification.max_absolute_error
              << ", max_rel_error=" << result.verification.max_relative_error
              << ", failures=" << result.verification.failure_count << std::defaultfloat << '\n';
    return result;
}

void write_csv(const std::string& path,
               const std::vector<CaseResult>& cases,
               const std::string& kernel_name) {
    const std::filesystem::path output_path(path);
    if (output_path.has_parent_path()) std::filesystem::create_directories(output_path.parent_path());
    std::ofstream output(output_path);
    if (!output) throw std::runtime_error("cannot open CSV output: " + path);
    output << "timestamp_utc,compiler,compiler_version,build_type,kernel,optimization_level,m,n,k,run,time_ms,gflops,verified,max_abs_error,max_rel_error\n";
    const std::string timestamp = utc_timestamp();
    output << std::setprecision(12);
    for (const CaseResult& item : cases) {
        for (const RunResult& run : item.runs) {
            output << timestamp << ',' << GEMM_COMPILER_ID << ',' << GEMM_COMPILER_VERSION << ','
                   << GEMM_BUILD_TYPE << ',' << kernel_name << ',' << GEMM_OPT_LEVEL << ',' << item.shape.m << ',' << item.shape.n << ',' << item.shape.k
                   << ',' << run.run << ',' << run.milliseconds << ',' << run.gflops << ','
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
        const GemmKernel kernel = select_kernel(options.kernel);
        const std::string loop_order = options.kernel == "ikj" ? "i-k-j" : "i-j-k";
        std::cout << "GEMM Optimization Lab - FP32 GEMM benchmark\n"
                  << "kernel=" << options.kernel << ", layout=row-major, loop-order=" << loop_order
                  << ", threads=1, warm-up=1, repeats=" << options.repeats
                  << ", optimization=" << GEMM_OPT_LEVEL << '\n';
        std::vector<CaseResult> results;
        bool all_passed = true;
        for (const Shape& shape : options.shapes) {
            results.push_back(benchmark_shape(shape, options.repeats, options.kernel, kernel));
            all_passed = results.back().verification.passed && all_passed;
        }
        if (!options.csv_path.empty()) write_csv(options.csv_path, results, options.kernel);
        return all_passed ? EXIT_SUCCESS : EXIT_FAILURE;
    } catch (const std::exception& error) {
        std::cerr << "error: " << error.what() << '\n';
        return EXIT_FAILURE;
    }
}
