#include "gemm_avx2_internal.hpp"

#include "microkernel_common.hpp"

#include <algorithm>
#include <stdexcept>
#include <thread>
#include <vector>

#if defined(__x86_64__) || defined(__i386__)
#define GEMM_X86 1
#else
#define GEMM_X86 0
#endif

namespace gemm {

void gemm_avx2_4x8_parallel(const Matrix& a,
                            const PackedB& packed_b,
                            Matrix& c,
                            std::size_t thread_count) {
    detail::validate_microkernel_shapes(a, packed_b, c);
    if (thread_count == 0) {
        throw std::invalid_argument(
            "thread_count must be positive");
    }
    if (!cpu_supports_avx2_fma()) {
        throw std::runtime_error(
            "AVX2/FMA is not supported by this CPU");
    }
#if GEMM_X86 && (defined(__GNUC__) || defined(__clang__))
    const std::size_t micro_row_groups =
        (a.rows() + detail::kMicroRows - 1) /
        detail::kMicroRows;
    const std::size_t worker_count =
        std::min(thread_count, micro_row_groups);
    if (worker_count == 1) {
        detail::gemm_avx2_row_range(
            a, packed_b, c, 0, a.rows());
        return;
    }

    // 每个 worker 获得连续且互不重叠的 4-row group。这样没有锁，也不会产生
    // C 元素的数据竞争；余数 group 分配给前面的 worker 以平衡工作量。
    std::vector<std::thread> workers;
    workers.reserve(worker_count);
    const std::size_t groups_per_worker =
        micro_row_groups / worker_count;
    const std::size_t remaining_groups =
        micro_row_groups % worker_count;
    std::size_t group_begin = 0;
    try {
        for (std::size_t worker = 0;
             worker < worker_count;
             ++worker) {
            const std::size_t group_count =
                groups_per_worker +
                (worker < remaining_groups ? 1 : 0);
            const std::size_t row_begin =
                group_begin * detail::kMicroRows;
            group_begin += group_count;
            const std::size_t row_end =
                std::min(
                    group_begin * detail::kMicroRows,
                    a.rows());
            workers.emplace_back(
                [&a, &packed_b, &c, row_begin, row_end] {
                    detail::gemm_avx2_row_range(
                        a,
                        packed_b,
                        c,
                        row_begin,
                        row_end);
                });
        }
    } catch (...) {
        for (std::thread& worker : workers) {
            if (worker.joinable()) {
                worker.join();
            }
        }
        throw;
    }
    for (std::thread& worker : workers) {
        worker.join();
    }
#else
    (void)a;
    (void)packed_b;
    (void)c;
    (void)thread_count;
    throw std::runtime_error(
        "AVX2/FMA kernel is unavailable in this build");
#endif
}

}  // namespace gemm

#undef GEMM_X86
