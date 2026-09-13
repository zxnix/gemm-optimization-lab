#include "benchmark_options.hpp"
#include "benchmark_output.hpp"
#include "benchmark_runner.hpp"

#include <cstdlib>
#include <exception>
#include <iostream>
#include <vector>

int main(int argc, char** argv) {
    try {
        const gemm::benchmark::ParsedOptions parsed =
            gemm::benchmark::parse_options(argc, argv);
        if (parsed.help_requested) {
            gemm::benchmark::print_usage(std::cout);
            return EXIT_SUCCESS;
        }

        const gemm::benchmark::Options& options = parsed.options;
        gemm::benchmark::ConsoleReporter reporter(std::cout);
        reporter.print_benchmark_header(options);

        std::vector<gemm::benchmark::CaseResult> results;
        bool all_passed = true;
        for (const gemm::benchmark::Shape& shape : options.shapes) {
            results.push_back(
                gemm::benchmark::benchmark_shape(
                    shape, options, reporter));
            if (results.back().verification_performed) {
                all_passed =
                    results.back().verification.passed && all_passed;
            }
        }
        if (!options.csv_path.empty()) {
            gemm::benchmark::write_csv(
                options.csv_path, results, options);
            reporter.print_csv_written(options.csv_path);
        }
        return all_passed ? EXIT_SUCCESS : EXIT_FAILURE;
    } catch (const std::exception& error) {
        std::cerr << "error: " << error.what() << '\n';
        return EXIT_FAILURE;
    }
}
