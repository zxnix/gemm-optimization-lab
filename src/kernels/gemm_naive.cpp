#include "gemm/gemm.hpp"

#include <stdexcept>

namespace gemm {

void gemm_naive(const Matrix& a, const Matrix& b, Matrix& c) {
    if (a.cols() != b.rows() || c.rows() != a.rows() || c.cols() != b.cols()) {
        throw std::invalid_argument("incompatible GEMM matrix dimensions");
    }

    const std::size_t m = a.rows();
    const std::size_t n = b.cols();
    const std::size_t k_size = a.cols();

    // i、j 是输出空间轴；k 是归约轴，每个 C(i,j) 对应一个长度为 K 的点积。
    for (std::size_t i = 0; i < m; ++i) {
        for (std::size_t j = 0; j < n; ++j) {
            float sum = 0.0F;
            // A(i,k) 连续；B(k,j) 的 stride 为 N*sizeof(float)。该低效行为被有意保留。
            for (std::size_t k = 0; k < k_size; ++k) {
                sum += a(i, k) * b(k, j);
            }
            c(i, j) = sum;
        }
    }
}

}  // namespace gemm
