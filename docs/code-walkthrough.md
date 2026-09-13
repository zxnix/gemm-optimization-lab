# GEMM 代码走读

## Matrix 与坐标轴

`Matrix` 用一个 `std::vector<float>` 拥有全部元素。逐元素访问不检查边界，因为它位于 GEMM 最内层；安全性由形状不变量和 kernel 入口检查保证。

| 循环 | 含义 |
|---|---|
| `i` | C 的行，spatial axis |
| `j` | C 的列，spatial axis |
| `k` | 点积累计方向，reduction axis |

## Kernel 演进

- `gemm_naive` 使用 `i-j-k`。row-major 下 `A(i,k)` 连续，而固定 j 改变 k 时，
  `B(k,j)` 每次跨过 B 的一整行。这一低效访问是 baseline 特征，永久保留。
- `gemm_ikj` 把 j 放在最内层，使 B 和 C 都沿行连续访问，同时重复使用
  `A(i,k)` 标量。
- `gemm_blocked` 在 `i-k-j` 外增加 `ii-jj-kk` tile 循环，限制局部工作集。
- `gemm_packed_b` 保持 blocked 的循环顺序，但从 tile-major `PackedB` 读取，
  用于隔离 B 物理布局的影响。

## Packing

`pack_b` 把 row-major B 的每个 K×N tile 复制到连续的 B×B 区域。逻辑元素仍然是
`B(k,j)`，变化的是它在物理 buffer 中的地址。边界 tile 用零填充，从而让每个 tile
拥有固定 stride；计算仍只遍历有效范围，所以 padding 不改变结果。

`PackedB` 的分配与 `pack_b` 的数据转换是不同成本。benchmark 在计时外预分配
workspace，单独测量 packing，再测量已打包 B 的 compute-only，同时报告
one-shot = packing + compute。

## Register Microkernel 与 AVX2/FMA

portable `gemm_microkernel_4x8` 用 32 个 FP32 accumulator 表达 4×8 输出块，并让
一个 packed B 行片段服务四个 A 行。`gemm_avx2_4x8` 把同一数据流显式 lowering
为四个 YMM accumulator：每个 k step 加载一个 8-lane B 向量，广播四个 A 标量，
再执行四条 packed FMA。

完整 4×8 块走 AVX2，边界块走 portable 路径。AVX2 公共入口先检查 CPU capability；
专用函数通过 target attribute 编译，因此不会让 generic 程序路径隐式要求 AVX2。
FMA 只有一次舍入，所以 AVX2 与非 FMA 结果允许存在正常的末位差异。

portable 调度位于 `gemm_microkernel.cpp`，intrinsic 与 target-specific row-range
位于 `gemm_avx2.cpp`。两者只通过私有 `microkernel_common.hpp` 共享 4×8 常量、
形状检查和边界 micro-tile。这样 translation unit 本身成为 ISA 边界：
`immintrin.h` 只出现在 AVX2 文件，generic portable 对象不会因为代码邻近而携带
AVX2/FMA 指令。

## Multithreading

`gemm_avx2_4x8_parallel` 沿 M 维把 4-row micro-tile group 静态分配给
`std::thread`。每个 worker 调用同一个 AVX2 row-range 内核，只读 A 与 PackedB，
并写入不重叠的 C 行。主线程等待全部 worker join 后才返回，因此调用者看到的仍是
同步 GEMM 语义。当前每次调用都会创建和销毁线程，生命周期成本有意包含在计时内。

线程创建、分区和 join 位于 `gemm_avx2_parallel.cpp`；实际向量计算仍由
`gemm_avx2.cpp` 中带 target attribute 的 row-range 完成。因此并行调度对象保持
generic ISA，同时多个 worker 复用同一个已验证的 AVX2 计算内核。

## Verification 与 Benchmark

验证器先把 FP32 输入提升为 FP64，再乘法和累加。benchmark 的矩阵分配、初始化、warm-up、统计、输出和验证都不进入正式 kernel 计时。

benchmark 在 CLI 边界通过 `parse_kernel_kind()` 把名称转换为强类型 `KernelKind`。
`KernelDescriptor` 集中保存 loop order、ISA、microkernel、packing、block size 与线程
能力，控制台和 CSV 都读取同一份 metadata；`execute_kernel()` 使用显式 `switch`
调用对应的 Phase 1 kernel。

## Benchmark 组件

`benchmark_main.cpp` 只保留顶层控制流：解析参数、打印实验配置、依次运行 shape、
按需写 CSV，并根据所有验证结果返回成功或失败。其余职责拆分如下：

- `benchmark_options` 把 CLI token 转换成 `Options`，并验证 sizes 与 M/N/K、
  kernel 与 threads、skip-verification 与 CSV 之间的约束；
- `benchmark_runner` 分配并初始化矩阵，准备 PackedB，执行一次 warm-up，再测量
  指定次数的 kernel，最后在计时外调用 FP64 verification；
- `benchmark_statistics` 集中实现 median 和 `2MNK / time`；
- `benchmark_output` 统一控制台格式与 CSV schema；
- `benchmark_types` 是这些组件之间传递配置和结果的数据契约。

`ConsoleReporter` 仍在每次 kernel 测量之后立即输出该次结果。这一选择保留了
Phase 1.1–1.7 的运行节奏；如果先连续测量七次、最后统一输出，虽然计时边界仍然正确，
却可能因为 CPU frequency、cache 状态和调度间隔不同而形成新的 benchmark 协议。
