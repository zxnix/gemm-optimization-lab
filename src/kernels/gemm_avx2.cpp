#include "gemm_avx2_internal.hpp"

#include "microkernel_common.hpp"

#include <algorithm>
#include <stdexcept>

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

#if GEMM_X86 && (defined(__GNUC__) || defined(__clang__))

GEMM_AVX2_FMA_TARGET
void compute_avx2_microtile_4x8(
    const Matrix& a,
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
    const std::size_t column_tile =
        column_tile_begin / block_size;

    for (std::size_t kk = 0;
         kk < a.cols();
         kk += block_size) {
        const std::size_t k_extent =
            std::min(block_size, a.cols() - kk);
        const std::size_t k_tile = kk / block_size;
        const float* packed_tile =
            packed_b.data() +
            (k_tile * n_tiles + column_tile) * tile_elements;
        for (std::size_t k = 0; k < k_extent; ++k) {
            // 一个 B 向量被四个输出行复用；每个 FMA 完成 8 次乘法和 8 次加法。
            const __m256 b_values = _mm256_loadu_ps(
                packed_tile + k * block_size + column_offset);
            c0 = _mm256_fmadd_ps(
                _mm256_set1_ps(a(row_begin, kk + k)),
                b_values,
                c0);
            c1 = _mm256_fmadd_ps(
                _mm256_set1_ps(a(row_begin + 1, kk + k)),
                b_values,
                c1);
            c2 = _mm256_fmadd_ps(
                _mm256_set1_ps(a(row_begin + 2, kk + k)),
                b_values,
                c2);
            c3 = _mm256_fmadd_ps(
                _mm256_set1_ps(a(row_begin + 3, kk + k)),
                b_values,
                c3);
        }
    }

    const std::size_t n = c.cols();
    _mm256_storeu_ps(
        c.data() + row_begin * n +
            column_tile_begin + column_offset,
        c0);
    _mm256_storeu_ps(
        c.data() + (row_begin + 1) * n +
            column_tile_begin + column_offset,
        c1);
    _mm256_storeu_ps(
        c.data() + (row_begin + 2) * n +
            column_tile_begin + column_offset,
        c2);
    _mm256_storeu_ps(
        c.data() + (row_begin + 3) * n +
            column_tile_begin + column_offset,
        c3);
}

#endif

}  // namespace

namespace detail {

#if GEMM_X86 && (defined(__GNUC__) || defined(__clang__))

GEMM_AVX2_FMA_TARGET
void gemm_avx2_row_range(const Matrix& a,
                         const PackedB& packed_b,
                         Matrix& c,
                         std::size_t row_begin,
                         std::size_t row_end) {
    const std::size_t block_size = packed_b.block_size();
    for (std::size_t ii = row_begin;
         ii < row_end;
         ii += block_size) {
        const std::size_t i_end =
            std::min(ii + block_size, row_end);
        for (std::size_t jj = 0;
             jj < packed_b.cols();
             jj += block_size) {
            const std::size_t j_extent =
                std::min(block_size, packed_b.cols() - jj);
            for (std::size_t i = ii;
                 i < i_end;
                 i += kMicroRows) {
                const std::size_t row_count =
                    std::min(kMicroRows, i_end - i);
                for (std::size_t j = 0;
                     j < j_extent;
                     j += kMicroCols) {
                    const std::size_t column_count =
                        std::min(kMicroCols, j_extent - j);
                    if (row_count == kMicroRows &&
                        column_count == kMicroCols) {
                        compute_avx2_microtile_4x8(
                            a, packed_b, c, i, jj, j);
                    } else {
                        // 非 4×8 边界块复用 portable 路径，避免越界加载和写回。
                        compute_portable_microtile(
                            a,
                            packed_b,
                            c,
                            i,
                            row_count,
                            jj,
                            j,
                            column_count);
                    }
                }
            }
        }
    }
}

#endif

}  // namespace detail

bool cpu_supports_avx2_fma() noexcept {
#if GEMM_X86 && (defined(__GNUC__) || defined(__clang__))
    __builtin_cpu_init();
    return __builtin_cpu_supports("avx2") &&
           __builtin_cpu_supports("fma");
#else
    return false;
#endif
}

void gemm_avx2_4x8(const Matrix& a,
                    const PackedB& packed_b,
                    Matrix& c) {
    detail::validate_microkernel_shapes(a, packed_b, c);
    if (!cpu_supports_avx2_fma()) {
        throw std::runtime_error(
            "AVX2/FMA is not supported by this CPU");
    }
#if GEMM_X86 && (defined(__GNUC__) || defined(__clang__))
    detail::gemm_avx2_row_range(
        a, packed_b, c, 0, a.rows());
#else
    (void)a;
    (void)packed_b;
    (void)c;
    throw std::runtime_error(
        "AVX2/FMA kernel is unavailable in this build");
#endif
}

}  // namespace gemm

#undef GEMM_AVX2_FMA_TARGET
#undef GEMM_X86
