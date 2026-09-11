#pragma once

#include "gemm/matrix.hpp"

namespace gemm {

// Baseline implementation: row-major storage and canonical i-j-k loop order.
void gemm_naive(const Matrix& a, const Matrix& b, Matrix& c);

}  // namespace gemm
