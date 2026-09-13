#include "kernel_registry.hpp"

#include "gemm/gemm.hpp"

#include <array>
#include <stdexcept>

namespace gemm::benchmark {
namespace {

constexpr std::array<KernelDescriptor, 7> kKernelDescriptors{{
    {KernelKind::Naive,
     "naive", "i-j-k", "generic", "none",
     false, false, false},
    {KernelKind::Ikj,
     "ikj", "i-k-j", "generic", "none",
     false, false, false},
    {KernelKind::Blocked,
     "blocked", "blocked-i-k-j", "generic", "none",
     false, true, false},
    {KernelKind::Packed,
     "packed", "packed-blocked-i-k-j", "generic", "none",
     true, true, false},
    {KernelKind::Micro,
     "micro", "packed-register-blocked", "generic", "4x8",
     true, true, false},
    {KernelKind::Avx2,
     "avx2", "packed-register-blocked", "avx2+fma", "4x8",
     true, true, false},
    {KernelKind::Avx2Multithreaded,
     "avx2-mt", "packed-register-blocked", "avx2+fma", "4x8",
     true, true, true},
}};

const PackedB& require_packed_b(const PackedB* packed_b) {
    if (packed_b == nullptr) {
        throw std::logic_error("packed B was not prepared");
    }
    return *packed_b;
}

}  // namespace

KernelKind parse_kernel_kind(std::string_view name) {
    for (const KernelDescriptor& descriptor : kKernelDescriptors) {
        if (descriptor.name == name) {
            return descriptor.kind;
        }
    }
    throw std::invalid_argument(
        "--kernel must be " + kernel_choices(", ", ", or "));
}

const KernelDescriptor& kernel_descriptor(KernelKind kind) {
    for (const KernelDescriptor& descriptor : kKernelDescriptors) {
        if (descriptor.kind == kind) {
            return descriptor;
        }
    }
    throw std::logic_error("invalid KernelKind");
}

std::string kernel_choices(std::string_view separator,
                           std::string_view final_separator) {
    std::string choices;
    for (std::size_t index = 0; index < kKernelDescriptors.size(); ++index) {
        if (index != 0) {
            const bool is_final_item = index + 1 == kKernelDescriptors.size();
            choices.append(is_final_item && !final_separator.empty()
                               ? final_separator
                               : separator);
        }
        choices.append(kKernelDescriptors[index].name);
    }
    return choices;
}

void execute_kernel(KernelKind kind,
                    const Matrix& a,
                    const Matrix& b,
                    Matrix& c,
                    const PackedB* packed_b,
                    std::size_t block_size,
                    std::size_t thread_count) {
    switch (kind) {
    case KernelKind::Naive:
        gemm_naive(a, b, c);
        return;
    case KernelKind::Ikj:
        gemm_ikj(a, b, c);
        return;
    case KernelKind::Blocked:
        gemm_blocked(a, b, c, block_size);
        return;
    case KernelKind::Packed:
        gemm_packed_b(a, require_packed_b(packed_b), c);
        return;
    case KernelKind::Micro:
        gemm_microkernel_4x8(a, require_packed_b(packed_b), c);
        return;
    case KernelKind::Avx2:
        gemm_avx2_4x8(a, require_packed_b(packed_b), c);
        return;
    case KernelKind::Avx2Multithreaded:
        gemm_avx2_4x8_parallel(
            a, require_packed_b(packed_b), c, thread_count);
        return;
    }
    throw std::logic_error("unhandled KernelKind");
}

}  // namespace gemm::benchmark
