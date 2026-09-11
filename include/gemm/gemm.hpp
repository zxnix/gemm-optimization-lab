#pragma once

#include "gemm/matrix.hpp"

namespace gemm {

/** @brief 使用单线程 i-j-k 循环计算并覆盖 C=A×B。
 * A 为 M×K、B 为 K×N、C 为 M×N。该对照实现有意不使用 blocking、packing、SIMD 或多线程。
 * @throws std::invalid_argument 矩阵形状不兼容时抛出。 */
void gemm_naive(const Matrix& a, const Matrix& b, Matrix& c);

}  // namespace gemm
