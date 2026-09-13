#include "microkernel_common.hpp"

#include <algorithm>

namespace gemm {
namespace {

void gemm_microkernel_portable_impl(const Matrix& a,
                                    const PackedB& packed_b,
                                    Matrix& c) {
    const std::size_t block_size = packed_b.block_size();
    for (std::size_t ii = 0;
         ii < a.rows();
         ii += block_size) {
        const std::size_t i_end =
            std::min(ii + block_size, a.rows());
        for (std::size_t jj = 0;
             jj < packed_b.cols();
             jj += block_size) {
            const std::size_t j_extent =
                std::min(block_size, packed_b.cols() - jj);
            for (std::size_t i = ii;
                 i < i_end;
                 i += detail::kMicroRows) {
                const std::size_t row_count =
                    std::min(detail::kMicroRows, i_end - i);
                for (std::size_t j = 0;
                     j < j_extent;
                     j += detail::kMicroCols) {
                    const std::size_t column_count =
                        std::min(
                            detail::kMicroCols,
                            j_extent - j);
                    detail::compute_portable_microtile(
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

}  // namespace

void gemm_microkernel_4x8(const Matrix& a,
                          const PackedB& packed_b,
                          Matrix& c) {
    detail::validate_microkernel_shapes(a, packed_b, c);
    gemm_microkernel_portable_impl(a, packed_b, c);
}

}  // namespace gemm
