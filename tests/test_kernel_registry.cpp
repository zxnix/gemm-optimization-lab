#include "kernel_registry.hpp"

#include <array>
#include <cstdlib>
#include <iostream>
#include <stdexcept>
#include <string_view>

namespace {

using gemm::benchmark::KernelDescriptor;
using gemm::benchmark::KernelKind;

void require(bool condition, const char* message) {
    if (!condition) {
        throw std::runtime_error(message);
    }
}

void test_all_cli_names_round_trip() {
    constexpr std::array<std::string_view, 7> names{
        "naive", "ikj", "blocked", "packed", "micro", "avx2", "avx2-mt"};
    for (const std::string_view name : names) {
        const KernelKind kind = gemm::benchmark::parse_kernel_kind(name);
        const KernelDescriptor& descriptor =
            gemm::benchmark::kernel_descriptor(kind);
        require(descriptor.name == name, "kernel name did not round-trip");
    }
    require(gemm::benchmark::kernel_choices("|") ==
                "naive|ikj|blocked|packed|micro|avx2|avx2-mt",
            "kernel choice list is inconsistent");
    require(gemm::benchmark::kernel_choices(", ", ", or ") ==
                "naive, ikj, blocked, packed, micro, avx2, or avx2-mt",
            "human-readable kernel choice list is inconsistent");
}

void test_key_capabilities() {
    const KernelDescriptor& naive =
        gemm::benchmark::kernel_descriptor(KernelKind::Naive);
    require(!naive.uses_packed_b && !naive.uses_block_size &&
                !naive.supports_threads,
            "naive descriptor has unexpected capabilities");

    const KernelDescriptor& parallel =
        gemm::benchmark::kernel_descriptor(KernelKind::Avx2Multithreaded);
    require(parallel.uses_packed_b && parallel.uses_block_size &&
                parallel.supports_threads,
            "multithreaded AVX2 descriptor is incomplete");
    require(parallel.target_isa == "avx2+fma" &&
                parallel.microkernel == "4x8",
            "multithreaded AVX2 code-generation metadata is wrong");
}

void test_invalid_name_is_rejected() {
    bool threw = false;
    try {
        (void)gemm::benchmark::parse_kernel_kind("unknown");
    } catch (const std::invalid_argument&) {
        threw = true;
    }
    require(threw, "unknown kernel name was not rejected");

    threw = false;
    try {
        (void)gemm::benchmark::kernel_descriptor(
            static_cast<KernelKind>(999));
    } catch (const std::logic_error&) {
        threw = true;
    }
    require(threw, "invalid KernelKind was not rejected");
}

}  // namespace

int main() {
    try {
        test_all_cli_names_round_trip();
        test_key_capabilities();
        test_invalid_name_is_rejected();
        std::cout << "All kernel registry tests passed.\n";
        return EXIT_SUCCESS;
    } catch (const std::exception& error) {
        std::cerr << "Test failure: " << error.what() << '\n';
        return EXIT_FAILURE;
    }
}
