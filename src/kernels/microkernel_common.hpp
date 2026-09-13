#pragma once

#include "gemm/gemm.hpp"

#include <algorithm>
#include <array>
#include <stdexcept>

namespace gemm::detail {

inline constexpr std::size_t kMicroRows = 4;
inline constexpr std::size_t kMicroCols = 8;

inline void validate_microkernel_shapes(const Matrix& a,
                                        const PackedB& packed_b,
                                        const Matrix& c) {
    if (a.cols() != packed_b.rows() ||
        c.rows() != a.rows() ||
        c.cols() != packed_b.cols()) {
        throw std::invalid_argument(
            "incompatible microkernel GEMM dimensions");
    }
}

inline void compute_portable_microtile(
    const Matrix& a,
    const PackedB& packed_b,
    Matrix& c,
    std::size_t row_begin,
    std::size_t row_count,
    std::size_t column_tile_begin,
    std::size_t column_offset,
    std::size_t column_count) {
    // 固定上限让编译器可以把小块 C 保存在寄存器中；只写回边界内的有效元素。
    std::array<float, kMicroRows * kMicroCols> accumulators{};
    const std::size_t block_size = packed_b.block_size();
    const std::size_t n_tiles = packed_b.n_tile_count();
    const std::size_t tile_elements = block_size * block_size;
    const std::size_t column_tile =
        column_tile_begin / block_size;

    for (std::size_t kk = 0; kk < a.cols(); kk += block_size) {
        const std::size_t k_extent =
            std::min(block_size, a.cols() - kk);
        const std::size_t k_tile = kk / block_size;
        const float* packed_tile =
            packed_b.data() +
            (k_tile * n_tiles + column_tile) * tile_elements;
        for (std::size_t k = 0; k < k_extent; ++k) {
            const float* packed_row =
                packed_tile + k * block_size + column_offset;
            for (std::size_t row = 0; row < row_count; ++row) {
                const float a_value =
                    a(row_begin + row, kk + k);
                for (std::size_t column = 0;
                     column < column_count;
                     ++column) {
                    accumulators[row * kMicroCols + column] +=
                        a_value * packed_row[column];
                }
            }
        }
    }

    for (std::size_t row = 0; row < row_count; ++row) {
        for (std::size_t column = 0;
             column < column_count;
             ++column) {
            c(row_begin + row,
              column_tile_begin + column_offset + column) =
                accumulators[row * kMicroCols + column];
        }
    }
}

}  // namespace gemm::detail
