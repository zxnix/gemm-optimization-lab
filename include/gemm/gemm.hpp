#pragma once

#include "gemm/matrix.hpp"
#include "gemm/packing.hpp"

namespace gemm {

/** @brief 使用单线程 i-j-k 循环计算并覆盖 C=A×B。
 * A 为 M×K、B 为 K×N、C 为 M×N。该对照实现有意不使用 blocking、packing、SIMD 或多线程。
 * @throws std::invalid_argument 矩阵形状不兼容时抛出。 */
void gemm_naive(const Matrix& a, const Matrix& b, Matrix& c);

/** @brief 使用单线程 i-k-j 循环计算并覆盖 C=A×B。
 * A 为 M×K、B 为 K×N、C 为 M×N。该实验 kernel 通过先清零 C，
 * 让 k 维成为复用 A 元素的中间循环，并保持 j 维的 row-major 连续访问。
 * @throws std::invalid_argument 矩阵形状不兼容时抛出。 */
void gemm_ikj(const Matrix& a, const Matrix& b, Matrix& c);

/** @brief 使用单线程 cache-blocked i-k-j 循环计算并覆盖 C=A×B。
 * block_size 同时控制 M、N、K 三个 tile 轴；边界 tile 可以小于该尺寸。
 * @throws std::invalid_argument 矩阵形状不兼容或 block_size 为零时抛出。 */
void gemm_blocked(const Matrix& a,
                  const Matrix& b,
                  Matrix& c,
                  std::size_t block_size);

/** @brief 使用预打包的 B，以单线程 blocked i-k-j 循环计算并覆盖 C=A×B。
 * A 为 M×K、packed_b 的逻辑形状为 K×N、C 为 M×N。packing 与计算分离，
 * 使 benchmark 能分别研究一次性使用和重复使用 B 的场景。
 * @throws std::invalid_argument 矩阵形状不兼容时抛出。 */
void gemm_packed_b(const Matrix& a, const PackedB& packed_b, Matrix& c);

/** @brief 使用 portable C++ 4×8 register microkernel 计算并覆盖 C=A×B。
 * 该实现消费 PackedB，但不使用 SIMD intrinsic，作为显式 AVX2/FMA 的控制组。
 * 编译器仍可能按照优化规则自动向量化普通 C++ 循环。
 * @throws std::invalid_argument 矩阵形状不兼容时抛出。 */
void gemm_microkernel_4x8(const Matrix& a, const PackedB& packed_b, Matrix& c);

/** @brief 使用 4×8 register microkernel 和 AVX2/FMA intrinsic 计算并覆盖 C=A×B。
 * 完整 4×8 micro-tile 使用四个 YMM 累加器；边界 micro-tile 使用 portable 路径。
 * @throws std::invalid_argument 矩阵形状不兼容时抛出。
 * @throws std::runtime_error 当前 CPU 不支持 AVX2 或 FMA 时抛出。 */
void gemm_avx2_4x8(const Matrix& a, const PackedB& packed_b, Matrix& c);

/** @brief 返回当前 x86 CPU 和操作系统上下文是否支持 AVX2 与 FMA。 */
[[nodiscard]] bool cpu_supports_avx2_fma() noexcept;

}  // namespace gemm
