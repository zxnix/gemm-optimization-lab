#pragma once

#include <cstddef>
#include <string>
#include <string_view>

namespace gemm {

class Matrix;
class PackedB;

namespace benchmark {

/** @brief benchmark 可选择的 GEMM kernel，避免用自由字符串表示内部状态。 */
enum class KernelKind {
    Naive,
    Ikj,
    Blocked,
    Packed,
    Micro,
    Avx2,
    Avx2Multithreaded,
};

/** @brief 集中描述一个 kernel 的 CLI 名称、代码生成特征和资源要求。 */
struct KernelDescriptor {
    KernelKind kind;
    std::string_view name;
    std::string_view loop_order;
    std::string_view target_isa;
    std::string_view microkernel;
    bool uses_packed_b;
    bool uses_block_size;
    bool supports_threads;
};

/** @brief 将 CLI kernel 名称转换为强类型枚举。
 * @throws std::invalid_argument 名称不属于已注册 kernel 时抛出。 */
[[nodiscard]] KernelKind parse_kernel_kind(std::string_view name);

/** @brief 返回指定 kernel 的唯一集中式元数据。
 * @throws std::logic_error kind 不是有效枚举值时抛出。 */
[[nodiscard]] const KernelDescriptor& kernel_descriptor(KernelKind kind);

/** @brief 按注册顺序连接全部 CLI kernel 名称，用于帮助和错误信息。
 * final_separator 为空时，最后一项之前仍使用 separator。 */
[[nodiscard]] std::string kernel_choices(
    std::string_view separator,
    std::string_view final_separator = {});

/** @brief 调用指定 kernel；packed_b 仅在 descriptor 要求时必须非空。 */
void execute_kernel(KernelKind kind,
                    const Matrix& a,
                    const Matrix& b,
                    Matrix& c,
                    const PackedB* packed_b,
                    std::size_t block_size,
                    std::size_t thread_count);

}  // namespace benchmark
}  // namespace gemm
