#include "benchmark_options.hpp"

#include "kernel_registry.hpp"

#include <limits>
#include <ostream>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

namespace gemm::benchmark {
namespace {

std::size_t parse_positive_size(const std::string& text, const char* name) {
    std::size_t parsed = 0;
    const unsigned long long value = std::stoull(text, &parsed);
    if (parsed != text.size() || value == 0) {
        throw std::invalid_argument(
            std::string(name) + " must be a positive integer");
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
    if (shapes.empty()) {
        throw std::invalid_argument("--sizes requires at least one size");
    }
    return shapes;
}

}  // namespace

ParsedOptions parse_options(int argc, char* const argv[]) {
    ParsedOptions parsed;
    Options& options = parsed.options;
    bool custom_sizes = false;
    bool rectangular = false;
    std::size_t m = 0;
    std::size_t n = 0;
    std::size_t k = 0;

    for (int index = 1; index < argc; ++index) {
        const std::string argument = argv[index];
        auto require_value = [&]() -> std::string {
            if (index + 1 >= argc) {
                throw std::invalid_argument(
                    "missing value for " + argument);
            }
            return argv[++index];
        };

        if (argument == "--repeats") {
            const std::size_t repeats =
                parse_positive_size(require_value(), "repeats");
            if (repeats >
                static_cast<std::size_t>(std::numeric_limits<int>::max())) {
                throw std::invalid_argument("repeats is too large");
            }
            options.repeats = static_cast<int>(repeats);
        } else if (argument == "--sizes") {
            options.shapes = parse_square_sizes(require_value());
            custom_sizes = true;
        } else if (argument == "--m") {
            m = parse_positive_size(require_value(), "M");
            rectangular = true;
        } else if (argument == "--n") {
            n = parse_positive_size(require_value(), "N");
            rectangular = true;
        } else if (argument == "--k") {
            k = parse_positive_size(require_value(), "K");
            rectangular = true;
        } else if (argument == "--csv") {
            options.csv_path = require_value();
        } else if (argument == "--kernel") {
            options.kernel = parse_kernel_kind(require_value());
        } else if (argument == "--block-size") {
            options.block_size =
                parse_positive_size(require_value(), "block-size");
        } else if (argument == "--threads") {
            options.thread_count =
                parse_positive_size(require_value(), "threads");
        } else if (argument == "--skip-verification") {
            options.verify_results = false;
        } else if (argument == "--help") {
            parsed.help_requested = true;
            return parsed;
        } else {
            throw std::invalid_argument(
                "unknown argument: " + argument);
        }
    }

    if (custom_sizes && rectangular) {
        throw std::invalid_argument(
            "--sizes cannot be combined with --m/--n/--k");
    }
    if (rectangular) {
        if (m == 0 || n == 0 || k == 0) {
            throw std::invalid_argument(
                "--m, --n, and --k must be provided together");
        }
        options.shapes = {{m, n, k}};
    }

    const KernelDescriptor& descriptor =
        kernel_descriptor(options.kernel);
    if (!descriptor.supports_threads && options.thread_count != 1) {
        throw std::invalid_argument(
            "--threads greater than 1 requires --kernel avx2-mt");
    }
    if (!options.verify_results && !options.csv_path.empty()) {
        throw std::invalid_argument(
            "--skip-verification cannot be combined with --csv");
    }
    return parsed;
}

void print_usage(std::ostream& output) {
    output
        << "Usage: gemm_benchmark [--repeats R] [--sizes S1,S2,...] "
           "[--m M --n N --k K] [--kernel "
        << kernel_choices("|")
        << "] [--block-size B] [--threads T] [--csv PATH] "
           "[--skip-verification]\n";
}

}  // namespace gemm::benchmark
