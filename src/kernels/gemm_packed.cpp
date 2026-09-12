#include "gemm/gemm.hpp"

#include <algorithm>
#include <limits>
#include <stdexcept>

namespace gemm {
namespace {

std::size_t ceil_div(std::size_t value, std::size_t divisor) {
    return value / divisor + static_cast<std::size_t>(value % divisor != 0);
}

std::size_t checked_packed_element_count(std::size_t rows,
                                         std::size_t cols,
                                         std::size_t block_size) {
    if (rows == 0 || cols == 0 || block_size == 0) {
        throw std::invalid_argument("packed B dimensions and block size must be positive");
    }

    const std::size_t k_tiles = ceil_div(rows, block_size);
    const std::size_t n_tiles = ceil_div(cols, block_size);
    const std::size_t maximum = std::numeric_limits<std::size_t>::max();
    if (block_size > maximum / block_size) {
        throw std::length_error("packed B tile size overflow");
    }
    const std::size_t tile_elements = block_size * block_size;
    if (k_tiles > maximum / n_tiles || k_tiles * n_tiles > maximum / tile_elements) {
        throw std::length_error("packed B element count overflow");
    }
    return k_tiles * n_tiles * tile_elements;
}

}  // namespace

PackedB::PackedB(std::size_t rows, std::size_t cols, std::size_t block_size)
    : rows_(rows),
      cols_(cols),
      block_size_(block_size),
      n_tile_count_(block_size == 0 ? 0 : ceil_div(cols, block_size)),
      data_(checked_packed_element_count(rows, cols, block_size), 0.0F) {}

void pack_b(const Matrix& b, PackedB& packed_b) {
    if (b.rows() != packed_b.rows() || b.cols() != packed_b.cols()) {
        throw std::invalid_argument("B and packed B dimensions do not match");
    }

    const std::size_t block_size = packed_b.block_size();
    const std::size_t n_tiles = packed_b.n_tile_count();
    const std::size_t tile_elements = block_size * block_size;
    std::fill(packed_b.data(), packed_b.data() +
                                  ceil_div(b.rows(), block_size) * n_tiles * tile_elements,
              0.0F);

    for (std::size_t kk = 0; kk < b.rows(); kk += block_size) {
        const std::size_t k_extent = std::min(block_size, b.rows() - kk);
        const std::size_t k_tile = kk / block_size;
        for (std::size_t jj = 0; jj < b.cols(); jj += block_size) {
            const std::size_t j_extent = std::min(block_size, b.cols() - jj);
            const std::size_t j_tile = jj / block_size;
            const std::size_t tile_offset =
                (k_tile * n_tiles + j_tile) * tile_elements;
            for (std::size_t k = 0; k < k_extent; ++k) {
                float* packed_row = packed_b.data() + tile_offset + k * block_size;
                const float* source_row = b.data() + (kk + k) * b.cols() + jj;
                std::copy_n(source_row, j_extent, packed_row);
            }
        }
    }
}

void gemm_packed_b(const Matrix& a, const PackedB& packed_b, Matrix& c) {
    if (a.cols() != packed_b.rows() || c.rows() != a.rows() ||
        c.cols() != packed_b.cols()) {
        throw std::invalid_argument("incompatible packed GEMM matrix dimensions");
    }

    const std::size_t m = a.rows();
    const std::size_t n = packed_b.cols();
    const std::size_t k_size = a.cols();
    const std::size_t block_size = packed_b.block_size();
    const std::size_t n_tiles = packed_b.n_tile_count();
    const std::size_t tile_elements = block_size * block_size;

    std::fill(c.data(), c.data() + m * n, 0.0F);

    // 外层和计算循环顺序与 gemm_blocked 相同，只将 B 的来源改为 packed tile。
    for (std::size_t ii = 0; ii < m; ii += block_size) {
        const std::size_t i_end = std::min(ii + block_size, m);
        for (std::size_t jj = 0; jj < n; jj += block_size) {
            const std::size_t j_end = std::min(jj + block_size, n);
            const std::size_t j_tile = jj / block_size;
            for (std::size_t kk = 0; kk < k_size; kk += block_size) {
                const std::size_t k_end = std::min(kk + block_size, k_size);
                const std::size_t k_tile = kk / block_size;
                const float* packed_tile = packed_b.data() +
                    (k_tile * n_tiles + j_tile) * tile_elements;
                for (std::size_t i = ii; i < i_end; ++i) {
                    for (std::size_t k = kk; k < k_end; ++k) {
                        const float a_value = a(i, k);
                        const float* packed_row =
                            packed_tile + (k - kk) * block_size;
                        for (std::size_t j = jj; j < j_end; ++j) {
                            c(i, j) += a_value * packed_row[j - jj];
                        }
                    }
                }
            }
        }
    }
}

}  // namespace gemm
