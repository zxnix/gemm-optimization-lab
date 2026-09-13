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
- `src/kernels/gemm_microkernel.cpp`：portable 4×8、AVX2/FMA 4×8 微内核与
  沿 M 维静态分区的 C++17 worker thread 调度。
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

`PackedB` 不改变 B 的逻辑 K×N 形状，而是把数据保存为
`[k_tile][n_tile][k_inner][n_inner]`，边界 tile 补零。packing API 与计算 API
分离，因此调用者可以只使用一次 packed B，也可以像神经网络权重一样重复使用。
