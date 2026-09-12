#include "gemm/gemm.hpp"

#include <algorithm>
#include <array>
#include <stdexcept>
#include <thread>
#include <vector>

#if defined(__x86_64__) || defined(__i386__)
#include <immintrin.h>
#define GEMM_X86 1
#else
#define GEMM_X86 0
#endif

#if GEMM_X86 && (defined(__GNUC__) || defined(__clang__))
#define GEMM_AVX2_FMA_TARGET __attribute__((target("avx2,fma")))
#else
#define GEMM_AVX2_FMA_TARGET
#endif

namespace gemm {
namespace {

constexpr std::size_t kMicroRows = 4;
constexpr std::size_t kMicroCols = 8;

void validate_microkernel_shapes(const Matrix& a,
                                 const PackedB& packed_b,
                                 const Matrix& c) {
    if (a.cols() != packed_b.rows() || c.rows() != a.rows() ||
        c.cols() != packed_b.cols()) {
        throw std::invalid_argument("incompatible microkernel GEMM dimensions");
    }
}

void compute_portable_microtile(const Matrix& a,
                                const PackedB& packed_b,
                                Matrix& c,
                                std::size_t row_begin,
                                std::size_t row_count,
                                std::size_t column_tile_begin,
                                std::size_t column_offset,
                                std::size_t column_count) {
    // 固定上限让编译器可以把小块 C 保存在寄存器中；只写回当前边界内的有效元素。
    std::array<float, kMicroRows * kMicroCols> accumulators{};
    const std::size_t block_size = packed_b.block_size();
    const std::size_t n_tiles = packed_b.n_tile_count();
    const std::size_t tile_elements = block_size * block_size;
    const std::size_t column_tile = column_tile_begin / block_size;

    for (std::size_t kk = 0; kk < a.cols(); kk += block_size) {
        const std::size_t k_extent = std::min(block_size, a.cols() - kk);
        const std::size_t k_tile = kk / block_size;
        const float* packed_tile = packed_b.data() +
            (k_tile * n_tiles + column_tile) * tile_elements;
        for (std::size_t k = 0; k < k_extent; ++k) {
            const float* packed_row =
                packed_tile + k * block_size + column_offset;
            for (std::size_t row = 0; row < row_count; ++row) {
                const float a_value = a(row_begin + row, kk + k);
                for (std::size_t column = 0; column < column_count; ++column) {
                    accumulators[row * kMicroCols + column] +=
                        a_value * packed_row[column];
                }
            }
        }
    }

    for (std::size_t row = 0; row < row_count; ++row) {
        for (std::size_t column = 0; column < column_count; ++column) {
            c(row_begin + row, column_tile_begin + column_offset + column) =
                accumulators[row * kMicroCols + column];
        }
    }
}

void gemm_microkernel_portable_impl(const Matrix& a,
                                    const PackedB& packed_b,
                                    Matrix& c) {
    const std::size_t block_size = packed_b.block_size();
    for (std::size_t ii = 0; ii < a.rows(); ii += block_size) {
        const std::size_t i_end = std::min(ii + block_size, a.rows());
        for (std::size_t jj = 0; jj < packed_b.cols(); jj += block_size) {
            const std::size_t j_extent =
                std::min(block_size, packed_b.cols() - jj);
            for (std::size_t i = ii; i < i_end; i += kMicroRows) {
                const std::size_t row_count =
                    std::min(kMicroRows, i_end - i);
                for (std::size_t j = 0; j < j_extent; j += kMicroCols) {
                    const std::size_t column_count =
                        std::min(kMicroCols, j_extent - j);
                    compute_portable_microtile(
                        a, packed_b, c, i, row_count, jj, j, column_count);
                }
            }
        }
    }
}

#if GEMM_X86 && (defined(__GNUC__) || defined(__clang__))

GEMM_AVX2_FMA_TARGET
void compute_avx2_microtile_4x8(const Matrix& a,
                                const PackedB& packed_b,
                                Matrix& c,
                                std::size_t row_begin,
                                std::size_t column_tile_begin,
                                std::size_t column_offset) {
    __m256 c0 = _mm256_setzero_ps();
    __m256 c1 = _mm256_setzero_ps();
    __m256 c2 = _mm256_setzero_ps();
    __m256 c3 = _mm256_setzero_ps();

    const std::size_t block_size = packed_b.block_size();
    const std::size_t n_tiles = packed_b.n_tile_count();
    const std::size_t tile_elements = block_size * block_size;
    const std::size_t column_tile = column_tile_begin / block_size;

    for (std::size_t kk = 0; kk < a.cols(); kk += block_size) {
        const std::size_t k_extent = std::min(block_size, a.cols() - kk);
        const std::size_t k_tile = kk / block_size;
        const float* packed_tile = packed_b.data() +
            (k_tile * n_tiles + column_tile) * tile_elements;
        for (std::size_t k = 0; k < k_extent; ++k) {
            // 一个 B 向量被四个输出行复用；每个 FMA 完成 8 次乘法和 8 次加法。
            const __m256 b_values = _mm256_loadu_ps(
                packed_tile + k * block_size + column_offset);
            c0 = _mm256_fmadd_ps(
                _mm256_set1_ps(a(row_begin, kk + k)), b_values, c0);
            c1 = _mm256_fmadd_ps(
                _mm256_set1_ps(a(row_begin + 1, kk + k)), b_values, c1);
            c2 = _mm256_fmadd_ps(
                _mm256_set1_ps(a(row_begin + 2, kk + k)), b_values, c2);
            c3 = _mm256_fmadd_ps(
                _mm256_set1_ps(a(row_begin + 3, kk + k)), b_values, c3);
        }
    }

    const std::size_t n = c.cols();
    _mm256_storeu_ps(c.data() + row_begin * n +
                         column_tile_begin + column_offset,
                     c0);
    _mm256_storeu_ps(c.data() + (row_begin + 1) * n +
                         column_tile_begin + column_offset,
                     c1);
    _mm256_storeu_ps(c.data() + (row_begin + 2) * n +
                         column_tile_begin + column_offset,
                     c2);
    _mm256_storeu_ps(c.data() + (row_begin + 3) * n +
                         column_tile_begin + column_offset,
                     c3);
}

GEMM_AVX2_FMA_TARGET
void gemm_avx2_row_range_impl(const Matrix& a,
                              const PackedB& packed_b,
                              Matrix& c,
                              std::size_t row_begin,
                              std::size_t row_end) {
    const std::size_t block_size = packed_b.block_size();
    for (std::size_t ii = row_begin; ii < row_end; ii += block_size) {
        const std::size_t i_end = std::min(ii + block_size, row_end);
        for (std::size_t jj = 0; jj < packed_b.cols(); jj += block_size) {
            const std::size_t j_extent =
                std::min(block_size, packed_b.cols() - jj);
            for (std::size_t i = ii; i < i_end; i += kMicroRows) {
                const std::size_t row_count =
                    std::min(kMicroRows, i_end - i);
                for (std::size_t j = 0; j < j_extent; j += kMicroCols) {
                    const std::size_t column_count =
                        std::min(kMicroCols, j_extent - j);
                    if (row_count == kMicroRows &&
                        column_count == kMicroCols) {
                        compute_avx2_microtile_4x8(
                            a, packed_b, c, i, jj, j);
                    } else {
                        // 非 4×8 边界块复用 portable 路径，避免越界向量加载和写回。
                        compute_portable_microtile(
                            a, packed_b, c, i, row_count, jj, j, column_count);
                    }
                }
            }
        }
    }
}

GEMM_AVX2_FMA_TARGET
void gemm_avx2_impl(const Matrix& a, const PackedB& packed_b, Matrix& c) {
    gemm_avx2_row_range_impl(a, packed_b, c, 0, a.rows());
}

#endif

}  // namespace

bool cpu_supports_avx2_fma() noexcept {
#if GEMM_X86 && (defined(__GNUC__) || defined(__clang__))
    __builtin_cpu_init();
    return __builtin_cpu_supports("avx2") && __builtin_cpu_supports("fma");
#else
    return false;
#endif
}

void gemm_microkernel_4x8(const Matrix& a,
                          const PackedB& packed_b,
                          Matrix& c) {
    validate_microkernel_shapes(a, packed_b, c);
    gemm_microkernel_portable_impl(a, packed_b, c);
}

void gemm_avx2_4x8(const Matrix& a, const PackedB& packed_b, Matrix& c) {
    validate_microkernel_shapes(a, packed_b, c);
    if (!cpu_supports_avx2_fma()) {
        throw std::runtime_error("AVX2/FMA is not supported by this CPU");
    }
#if GEMM_X86 && (defined(__GNUC__) || defined(__clang__))
    gemm_avx2_impl(a, packed_b, c);
#else
    (void)a;
    (void)packed_b;
    (void)c;
    throw std::runtime_error("AVX2/FMA kernel is unavailable in this build");
#endif
}

void gemm_avx2_4x8_parallel(const Matrix& a,
                            const PackedB& packed_b,
                            Matrix& c,
                            std::size_t thread_count) {
    validate_microkernel_shapes(a, packed_b, c);
    if (thread_count == 0) {
        throw std::invalid_argument("thread_count must be positive");
    }
    if (!cpu_supports_avx2_fma()) {
        throw std::runtime_error("AVX2/FMA is not supported by this CPU");
    }
#if GEMM_X86 && (defined(__GNUC__) || defined(__clang__))
    const std::size_t micro_row_groups =
        (a.rows() + kMicroRows - 1) / kMicroRows;
    const std::size_t worker_count =
        std::min(thread_count, micro_row_groups);
    if (worker_count == 1) {
        gemm_avx2_row_range_impl(a, packed_b, c, 0, a.rows());
        return;
    }

    // 每个 worker 获得连续且互不重叠的 4-row group。这样没有锁，也不会产生
    // C 元素的数据竞争；余数 group 分配给前面的 worker 以平衡工作量。
    std::vector<std::thread> workers;
    workers.reserve(worker_count);
    const std::size_t groups_per_worker = micro_row_groups / worker_count;
    const std::size_t remaining_groups = micro_row_groups % worker_count;
    std::size_t group_begin = 0;
    try {
        for (std::size_t worker = 0; worker < worker_count; ++worker) {
            const std::size_t group_count =
                groups_per_worker + (worker < remaining_groups ? 1 : 0);
            const std::size_t row_begin = group_begin * kMicroRows;
            group_begin += group_count;
            const std::size_t row_end =
                std::min(group_begin * kMicroRows, a.rows());
            workers.emplace_back([&a, &packed_b, &c, row_begin, row_end] {
                gemm_avx2_row_range_impl(
                    a, packed_b, c, row_begin, row_end);
            });
        }
    } catch (...) {
        for (std::thread& worker : workers) {
            if (worker.joinable()) worker.join();
        }
        throw;
    }
    for (std::thread& worker : workers) worker.join();
#else
    (void)a;
    (void)packed_b;
    (void)c;
    (void)thread_count;
    throw std::runtime_error("AVX2/FMA kernel is unavailable in this build");
#endif
}

}  // namespace gemm

#undef GEMM_AVX2_FMA_TARGET
#undef GEMM_X86
