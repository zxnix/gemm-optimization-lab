# Phase 1.6：Register Microkernel 与 AVX2/FMA

## 研究问题

在 B 已经采用 tile-major packed layout 后，固定尺寸 register microkernel 能否减少
C 的反复读写和循环管理成本？显式 AVX2/FMA 相比结构相同的 portable C++ 微内核
还能带来多少提升？

## 背景原理

AVX2 的 YMM 寄存器宽 256 bit，可以同时保存 8 个 FP32 元素。4×8 microkernel
一次计算 C 的 4 行、8 列，并使用四个 YMM 寄存器保存 32 个部分和。

每个 k step：

- 连续加载 8 个 packed B 元素；
- 分别广播 4 个 A 标量；
- 执行 4 条 packed FMA；
- 完成 `4 × 8 × 2 = 64 FLOPs`。

一个 B 向量被四个输出行复用，C 的部分和跨越整个 K 维保留在寄存器中，最后只写回
一次。这就是 register blocking。8 列来自 YMM 的 FP32 lane 数；4 行是在 B 复用和
register pressure 之间选择的第一个教学型设计点。

## 设计方案

项目新增两个使用相同 4×8 调度的 kernel：

- `micro`：portable C++ 累加器数组，不使用 intrinsic；编译器仍可能自动向量化；
- `avx2`：完整 4×8 micro-tile 使用 `__m256`、`_mm256_loadu_ps`、
  `_mm256_set1_ps`、`_mm256_fmadd_ps` 和 `_mm256_storeu_ps`。

M 或 N 边界不足 4×8 时，AVX2 kernel 使用 portable 边界路径，避免越界加载和写回。
K 可以为任意正整数。当前使用 unaligned load/store，不要求 `std::vector` 地址或
leading dimension 具有 32-byte alignment。

AVX2/FMA 只通过 GCC/Clang function target attribute 应用于专用函数，不给整个程序
添加全局 `-mavx2 -mfma`。公共入口先进行运行时 CPU capability check；因此 generic
kernel 和测试仍能在不支持 AVX2 的 x86 CPU 上构建，专用 kernel 则明确拒绝执行。

## 实验假设

- portable 4×8 microkernel 将因 C 寄存器驻留和 B 跨行复用而超过普通 packed kernel；
- explicit AVX2/FMA 将超过 portable control；
- FMA 把乘法和加法合为一次舍入，误差可能与非 FMA 路径略有不同，但应通过现有
  FP64 reference 与联合容限；
- block size 仍可能影响 packed panel 的 cache 行为，因此测试 64 和 128。

## 控制变量

- 同一个 git revision、GCC Release/`-O3`；
- 相同 FP32 输入、PackedB layout、block size 与 FP64 verification；
- 相同 4×8 microkernel schedule 用于 `micro` 和 `avx2`；
- 单线程、一次 warm-up、七次正式运行；
- 不使用 OpenMP、BLAS、`-march=native` 或 `-ffast-math`。

比较关系：

~~~text
packed → micro   register blocking 与 microkernel schedule
micro  → avx2    explicit 256-bit SIMD 与 FMA
ikj    → avx2    当前最佳简单实现与专用内核的端到端对照
~~~

portable C++ 版本是否被编译器自动向量化必须通过 Assembly 记录，不能仅凭源码名称
假定它只使用标量指令。

## 计时边界

与 Phase 1.5 相同，PackedB workspace 分配不计时，packing 和 GEMM 分开 warm-up 与
测量。`time_ms` 是 compute-only；`one_shot_time_ms` 是 packing 与 kernel 样本之和。
神经网络权重重复使用场景主要看 compute-only，单次矩阵乘法同时看 one-shot。

## 运行方法

~~~bash
./scripts/run_simd.sh
~~~

默认比较 256³、512³、1024³，以及 block size 64、128。快速检查：

~~~bash
GEMM_SIZES=128,256 GEMM_REPEATS=2 GEMM_BLOCK_SIZES=64 \
    ./scripts/run_simd.sh /tmp/gemm-simd
~~~

单独运行：

~~~bash
./build/release/gemm_benchmark --kernel micro --block-size 64
./build/release/gemm_benchmark --kernel avx2 --block-size 64
~~~

## 生成代码验证

~~~bash
./scripts/generate_codegen_reports.sh
~~~

AVX2 实现必须在 Assembly 中出现 YMM 与 packed FMA 指令。portable control 的真实
代码生成也需要记录。源码中的 intrinsic 只是意图，Assembly 才是 CPU 将执行的证据。

## 结果

正式结果见 [`results/phase1/simd/summary.md`](../../results/phase1/simd/summary.md)。
最佳 AVX2/FMA 4×8 kernel 在 256³、512³、1024³ 上分别达到 56.511、57.630 和
53.416 GFLOP/s，相对本轮 `i-k-j` median 分别加速 3.758×、3.979× 和 3.532×。
portable 4×8 没有超过 matched packed baseline，说明微内核源码形状本身并不保证
理想寄存器分配。

## 解释边界

当前 4×8 只是第一个教学型微内核，不代表最优形状。未测试 aligned allocation、
更大的 MR×NR、A packing、software prefetch 或多级 cache 参数。WSL2 数据仍只作为
开发趋势；正式结论需要原生 Linux、CPU affinity、稳定频率和硬件计数器。

## 与后续阶段的连接

微内核把 GEMM 从三层循环具体 lowering 为寄存器级指令序列，对应 Tensor Compiler
中的 vectorization、unrolling、bufferization 和 target-specific code generation。
生成的 LLVM IR 与 Assembly 将成为 Phase 2 分析的直接输入。
