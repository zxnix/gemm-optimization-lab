#pragma once

#include <cstddef>
#include <cstdint>
#include <random>
#include <stdexcept>
#include <vector>

namespace gemm {

/** @brief 使用连续 FP32 内存保存的 row-major 二维矩阵。
 * 元素 (row,col) 映射为 data[row*cols+col]；访问不检查边界以免污染内层性能。 */
class Matrix {
public:
    /** @throws std::invalid_argument 任一维度为零时抛出。 */
    Matrix(std::size_t rows, std::size_t cols)
        : rows_(rows), cols_(cols), data_(rows * cols, 0.0F) {
        if (rows == 0 || cols == 0) {
            throw std::invalid_argument("matrix dimensions must be positive");
        }
    }

    [[nodiscard]] std::size_t rows() const noexcept { return rows_; }
    [[nodiscard]] std::size_t cols() const noexcept { return cols_; }
    [[nodiscard]] float* data() noexcept { return data_.data(); }
    [[nodiscard]] const float* data() const noexcept { return data_.data(); }

    float& operator()(std::size_t row, std::size_t col) noexcept {
        return data_[row * cols_ + col];
    }

    const float& operator()(std::size_t row, std::size_t col) const noexcept {
        return data_[row * cols_ + col];
    }

private:
    std::size_t rows_;
    std::size_t cols_;
    std::vector<float> data_;
};

/** @brief 用固定种子的 [-1,1] 均匀分布初始化，保证不同 kernel 输入一致。 */
inline void fill_random(Matrix& matrix, std::uint32_t seed) {
    std::mt19937 generator(seed);
    std::uniform_real_distribution<float> distribution(-1.0F, 1.0F);
    const std::size_t count = matrix.rows() * matrix.cols();
    for (std::size_t index = 0; index < count; ++index) {
        matrix.data()[index] = distribution(generator);
    }
}

}  // namespace gemm
