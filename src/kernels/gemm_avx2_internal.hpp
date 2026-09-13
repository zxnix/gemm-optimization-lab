#pragma once

#include "gemm/gemm.hpp"

namespace gemm::detail {

/** @brief 仅供单线程与多线程 AVX2 入口共享的内部 row-range kernel。 */
void gemm_avx2_row_range(const Matrix& a,
                         const PackedB& packed_b,
                         Matrix& c,
                         std::size_t row_begin,
                         std::size_t row_end);

}  // namespace gemm::detail
