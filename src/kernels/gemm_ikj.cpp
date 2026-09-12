#include "gemm/gemm.hpp"

#include <stdexcept>

namespace gemm {

void gemm_ikj(const Matrix& a, const Matrix& b, Matrix& c) {
    if (a.cols() != b.rows() || c.rows() != a.rows() || c.cols() != b.cols()) {
        throw std::invalid_argument("incompatible GEMM matrix dimensions");
    }

    const std::size_t m = a.rows();
    const std::size_t n = b.cols();
    const std::size_t k_size = a.cols();

    // i-k-j 需要累加到 C，因此先清零；j 是最内层，连续访问 row-major 的 B 行和 C 行。
    for (std::size_t i = 0; i < m; ++i) {
        for (std::size_t j = 0; j < n; ++j) {
            c(i, j) = 0.0F;
        }
    }

    for (std::size_t i = 0; i < m; ++i) {
        for (std::size_t k = 0; k < k_size; ++k) {
            const float a_value = a(i, k);
            for (std::size_t j = 0; j < n; ++j) {
                c(i, j) += a_value * b(k, j);
            }
        }
    }
}

}  // namespace gemm
