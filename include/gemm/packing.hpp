#pragma once

#include <cstddef>
#include <vector>

namespace gemm {

class Matrix;

/** @brief B 矩阵的 tile-major FP32 packed 表示。
 *
 * 原始 B 的形状为 K×N。存储顺序依次为 K tile、N tile、tile 内的 k、tile 内的 j；
 * 每个 tile 补齐为 block_size×block_size，边界之外填零。该类只负责拥有预分配的
 * 连续存储，实际数据转换由 pack_b 完成。
 */
class PackedB {
public:
    /** @throws std::invalid_argument K、N 或 block_size 为零时抛出。 */
    PackedB(std::size_t rows, std::size_t cols, std::size_t block_size);

    [[nodiscard]] std::size_t rows() const noexcept { return rows_; }
    [[nodiscard]] std::size_t cols() const noexcept { return cols_; }
    [[nodiscard]] std::size_t block_size() const noexcept { return block_size_; }
    [[nodiscard]] std::size_t n_tile_count() const noexcept { return n_tile_count_; }
    [[nodiscard]] float* data() noexcept { return data_.data(); }
    [[nodiscard]] const float* data() const noexcept { return data_.data(); }

private:
    std::size_t rows_;
    std::size_t cols_;
    std::size_t block_size_;
    std::size_t n_tile_count_;
    std::vector<float> data_;
};

/** @brief 将 row-major K×N 矩阵 B 转换并覆盖到预分配的 tile-major packed_b。
 * @throws std::invalid_argument B 与 packed_b 的逻辑形状不同时抛出。 */
void pack_b(const Matrix& b, PackedB& packed_b);

}  // namespace gemm
