#include "gemm/gemm.hpp"

#include <algorithm>
#include <stdexcept>

namespace gemm {

void gemm_blocked(const Matrix& a,
                  const Matrix& b,
                  Matrix& c,
                  std::size_t block_size) {
    if (a.cols() != b.rows() || c.rows() != a.rows() || c.cols() != b.cols()) {
        throw std::invalid_argument("incompatible GEMM matrix dimensions");
    }
    if (block_size == 0) {
        throw std::invalid_argument("block size must be positive");
    }

    const std::size_t m = a.rows();
    const std::size_t n = b.cols();
    const std::size_t k_size = a.cols();

    // C 只清零一次；后续每个 K tile 都向同一个 C tile 累加。
    for (std::size_t i = 0; i < m; ++i) {
        for (std::size_t j = 0; j < n; ++j) {
            c(i, j) = 0.0F;
        }
    }

    for (std::size_t ii = 0; ii < m; ii += block_size) {
        const std::size_t i_end = std::min(ii + block_size, m);
        for (std::size_t jj = 0; jj < n; jj += block_size) {
            const std::size_t j_end = std::min(jj + block_size, n);
            for (std::size_t kk = 0; kk < k_size; kk += block_size) {
                const std::size_t k_end = std::min(kk + block_size, k_size);
                // tile 内保持 i-k-j：A 标量复用，B/C 沿 row-major 行连续访问。
                for (std::size_t i = ii; i < i_end; ++i) {
                    for (std::size_t k = kk; k < k_end; ++k) {
                        const float a_value = a(i, k);
                        for (std::size_t j = jj; j < j_end; ++j) {
                            c(i, j) += a_value * b(k, j);
                        }
                    }
                }
            }
        }
    }
}

}  // namespace gemm
