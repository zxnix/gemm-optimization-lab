#pragma once

#include "gemm/matrix.hpp"

#include <cstddef>

namespace gemm {

/** @brief 汇总 FP32 结果与 FP64 reference 的逐元素误差。 */
struct VerificationResult {
    bool passed = false;
    std::size_t failure_count = 0;
    std::size_t worst_row = 0;
    std::size_t worst_col = 0;
    double max_absolute_error = 0.0;
    double max_relative_error = 0.0;
    double computed_at_worst = 0.0;
    double reference_at_worst = 0.0;
};

/** @brief 用 FP64 乘法和累加生成 reference，并按绝对/相对联合容限验证。 */
VerificationResult verify_gemm(const Matrix& a,
                               const Matrix& b,
                               const Matrix& computed,
                               double absolute_tolerance = 1.0e-4,
                               double relative_tolerance = 1.0e-4);

}  // namespace gemm
