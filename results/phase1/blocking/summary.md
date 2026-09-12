# Phase 1.4 实验结果：Cache Blocking

## 实验环境

- 源码版本：`55a1bce21728157ec787e562b27dcaf925b984e9`
- 系统：Fedora Linux 44 on WSL2，Linux 6.6.87.2
- CPU：13th Gen Intel Core i9-13905H，20 logical CPUs
- 编译器：GCC 16.1.1
- 构建：Release，`-O3 -DNDEBUG`
- 协议：一次 warm-up，七次正式运行；下表使用 median

`i-k-j` 与所有 blocked kernel 使用相同输入、相同验证和相同计时边界。所有组合均为 `verify: PASS`。

## 测量结果

| Kernel | 256³ median (ms) | 256³ GFLOP/s | 512³ median (ms) | 512³ GFLOP/s | 1024³ median (ms) | 1024³ GFLOP/s |
|---|---:|---:|---:|---:|---:|---:|
| `i-k-j` | 1.612 | 20.815 | 12.576 | 21.344 | 98.511 | 21.799 |
| blocked-16 | 2.903 | 11.560 | 24.713 | 10.862 | 222.927 | 9.633 |
| blocked-32 | 2.030 | 16.526 | 18.238 | 14.719 | 158.441 | 13.554 |
| blocked-64 | 1.871 | 17.935 | 15.740 | 17.055 | 134.596 | 15.955 |
| blocked-128 | 1.616 | 20.765 | 13.561 | 19.795 | 127.369 | 16.860 |

相对 `i-k-j` baseline 的耗时比为：

| Tile | 256³ | 512³ | 1024³ |
|---|---:|---:|---:|
| 16 | 1.801× | 1.965× | 2.263× |
| 32 | 1.259× | 1.450× | 1.608× |
| 64 | 1.161× | 1.252× | 1.366× |
| 128 | 1.002× | 1.078× | 1.293× |

数值越大表示 blocked kernel 越慢。四个测试尺寸中，`i-k-j` baseline 都是最快或接近最快的实现。

## 结果解释

`i-k-j` 已经让 B 和 C 在内层 j 循环中连续访问，并复用 A 的一个标量。对于当前 GCC/CPU，blocked kernel 虽然限制了 tile 工作集，但同时引入了：

- 三层 tile 循环；
- tile 边界计算；
- 多次进入内层循环；
- C 的清零成本；
- 当前实现尚未进行 packing 或专用微内核。

在本实验范围内，这些成本抵消甚至超过了额外 cache reuse 的收益。block size 从 16 增大到 128 时性能持续改善，说明小 tile 的循环管理开销明显；但即使 128 tile，也没有在 512³ 和 1024³ 上超过 unblocked `i-k-j`。

这是一条有效的实验结论：cache blocking 不是独立于数据布局、编译器和微内核的自动加速开关。

## 生成代码证据

补充审计显示，`gemm_ikj` 和 `gemm_blocked` 的最内层 j 循环都被 GCC `-O3` 向量化：

- 两者都使用 16-byte XMM packed 向量；
- Assembly 都出现 `mulps/addps`；
- 两者都有 8-byte epilogue 和 `mulss/addss` 标量 remainder；
- blocked 外层 tile 循环因嵌套与控制流没有被向量化，这是预期现象；
- 两者都没有使用 YMM、ZMM 或 FMA。

证据位于 `artifacts/phase1/codegen-o3/`。因此可以排除“blocked kernel 完全没有 SIMD”这一解释。当前性能差异仍可能来自 tile 循环与边界管理、较短的向量循环、cache 行为及未进行 packing/寄存器微内核等因素；没有硬件计数器时不能进一步唯一归因。

## 结论与下一步

Phase 1.4 完成了 cache blocking 的基础实现和 tile size 对比，但没有宣称性能提升。下一步将进入 matrix packing，把 B 转换为更适合连续加载的布局，再单独测量 packing 对 blocked kernel 的影响；随后再进入 SIMD/AVX 微内核。
