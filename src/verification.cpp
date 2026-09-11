#include "gemm/verification.hpp"

#include <algorithm>
#include <cmath>
#include <stdexcept>

namespace gemm {

VerificationResult verify_gemm(const Matrix& a,
                               const Matrix& b,
                               const Matrix& computed,
                               double absolute_tolerance,
                               double relative_tolerance) {
    if (a.cols() != b.rows() || computed.rows() != a.rows() ||
        computed.cols() != b.cols()) {
        throw std::invalid_argument("incompatible verification matrix dimensions");
    }

    VerificationResult result;
    for (std::size_t i = 0; i < a.rows(); ++i) {
        for (std::size_t j = 0; j < b.cols(); ++j) {
            double reference = 0.0;
            for (std::size_t k = 0; k < a.cols(); ++k) {
                reference += static_cast<double>(a(i, k)) * static_cast<double>(b(k, j));
            }

            const double actual = static_cast<double>(computed(i, j));
            const double absolute_error = std::abs(actual - reference);
            const double relative_error =
                absolute_error / std::max(std::abs(reference), 1.0e-12);

            if (absolute_error > result.max_absolute_error) {
                result.max_absolute_error = absolute_error;
                result.worst_row = i;
                result.worst_col = j;
                result.computed_at_worst = actual;
                result.reference_at_worst = reference;
            }
            result.max_relative_error = std::max(result.max_relative_error, relative_error);

            if (absolute_error > absolute_tolerance + relative_tolerance * std::abs(reference)) {
                ++result.failure_count;
            }
        }
    }
    result.passed = result.failure_count == 0;
    return result;
}

}  // namespace gemm
