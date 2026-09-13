# 项目结构与职责

当前对象是 FP32 稠密矩阵乘法：`A(M×K) · B(K×N) = C(M×N)`。naive 到
AVX2 的历史 kernel 保持单线程，Phase 1.7 另设多线程实验入口。

```text
Matrix（逻辑 row-major 数据）
  ├── gemm_naive
  ├── gemm_ikj
  ├── gemm_blocked
  ├── pack_b ──→ PackedB（tile-major 物理布局）
  │                    ├── gemm_packed_b
  │                    ├── gemm_microkernel_4x8
  │                    ├── gemm_avx2_4x8
  │                    └── gemm_avx2_4x8_parallel
  └── verify_gemm（FP64 reference）
                    ↑
             benchmark 与 tests
```

- `matrix.hpp`：形状、连续内存和 row-major 索引。
- `packing.hpp`：packed B 的逻辑形状、block size 和连续 workspace。
- `src/kernels/gemm_naive.cpp`：永久保留的 `i-j-k` 对照实现。
- `src/kernels/gemm_ikj.cpp`：连续访问 B/C 的 `i-k-j` 实现。
- `src/kernels/gemm_blocked.cpp`：三维 cache blocking 对照。
- `src/kernels/gemm_packed.cpp`：B layout transformation 与 packed kernel。
- `src/kernels/gemm_microkernel.cpp`：portable C++ 4×8 microkernel。
- `src/kernels/gemm_avx2.cpp`：CPU capability check、AVX2/FMA 4×8 microkernel
  和仅处理指定 M 行区间的内部 kernel。
- `src/kernels/gemm_avx2_parallel.cpp`：沿 M 维静态分区的 C++17 worker
  thread 调度，不直接包含 SIMD intrinsic。
- `src/kernels/microkernel_common.hpp`：仅供上述实现共享的 shape validation、
  micro-tile 常量和 portable 边界路径。
- `src/kernels/gemm_avx2_internal.hpp`：单线程与多线程入口之间的私有
  row-range 接口。
- `src/verification/verification.cpp`：FP64 reference 与误差报告。
- `src/benchmark/kernel_registry.*`：强类型 kernel 标识、集中 metadata 与执行分派。
- `src/benchmark/benchmark_types.hpp`：shape、options、单次运行与 case result。
- `src/benchmark/benchmark_options.*`：CLI 解析、帮助文本和跨参数约束。
- `src/benchmark/benchmark_statistics.*`：median 与 2MNK GFLOP/s 计算。
- `src/benchmark/benchmark_runner.*`：初始化、packing、warm-up、计时与验证流程。
- `src/benchmark/benchmark_output.*`：控制台报告和稳定 CSV schema。
- `src/benchmark/benchmark_main.cpp`：组合上述组件并决定进程退出状态。
- `test_gemm.cpp`：手工结果、随机非方阵和非法维度测试。

二维元素 `(row,col)` 映射为 `row*cols+col`。行内连续，跨行 stride 为 `cols*sizeof(float)`。核心库不依赖 benchmark 或 tests，后续可替换 kernel 而不改变测量工具。

benchmark 组件之间的数据流为：

```text
CLI → ParsedOptions → benchmark runner → CaseResult → console / CSV
                         │
                         └── KernelKind → kernel registry → GEMM kernel
```

`gemm_benchmark_support` 是仅供 benchmark 与测试使用的内部 CMake target，不属于
GEMM 公共 API。拆分后，入口文件不再包含参数规则、计时细节或 CSV 字段。

CMake target 依赖关系为：

```text
Threads::Threads
      ↓
  gemm_core ─────────────→ gemm_tests
      ↓
gemm_benchmark_support ──→ registry/options tests
      ↓
gemm_benchmark
```

`gemm_core` 包含所有 Phase 1 kernel 和 verification 实现。它不再使用
`gemm_baseline` 这一旧名称，因为该 target 早已不只包含 naive baseline；
同时它也不命名为 `gemm_kernels`，因为 verification 同样属于该构建单元。

## 自动化保护

- `gemm_correctness`：所有计算 kernel、边界形状与错误处理；
- `gemm_kernel_registry`：CLI 名称、descriptor 和执行分派；
- `gemm_benchmark_options`：参数默认值、组合与错误信息；
- `gemm_benchmark_components`：统计公式、控制台格式和 22 列 CSV schema；
- `gemm_benchmark_smoke`：通过真实可执行文件运行 packing、计算与验证；
- `gemm_isa_boundaries`：审计 portable、AVX2 和 parallel scheduler 对象。

`.editorconfig` 定义 LF、末尾换行、空格缩进和 C++ 100 列规则；
`scripts/check_style.sh` 在 CI 中检查全部源码和文档，但有意排除不可变的历史
`artifacts/` 与 `results/`。

`PackedB` 不改变 B 的逻辑 K×N 形状，而是把数据保存为
`[k_tile][n_tile][k_inner][n_inner]`，边界 tile 补零。packing API 与计算 API
分离，因此调用者可以只使用一次 packed B，也可以像神经网络权重一样重复使用。
