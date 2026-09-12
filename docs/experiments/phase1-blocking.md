# Phase 1.4：Cache Blocking 实验

## 研究问题

在已经改善循环顺序的 `i-k-j` GEMM 上引入三维 tile，是否能让 A、B、C 的工作集更稳定地留在 cache 中，从而继续提升性能？

## 实验假设

对于 block size 为 B 的 tile，局部工作集大致包含三个 `B×B` FP32 tile：

```text
working_set ≈ 3 × B² × sizeof(float)
```

较小的 tile 可能提高 cache reuse，但会增加外层循环和边界判断；较大的 tile 减少循环管理开销，却可能超出较小 cache 层级。预期存在与硬件 cache 和编译器代码生成共同相关的较优尺寸。

## 控制变量

固定以下条件，只改变 blocked kernel 的 block size：

- 同一个 git revision；
- GCC Release/`-O3`；
- FP32、row-major、单线程；
- 相同随机种子、矩阵规模和 FP64 verification；
- 一次 warm-up、七次正式测量；
- 不使用 packing、SIMD intrinsic、OpenMP 或 `-march=native`。

`i-k-j` 作为 unblocked baseline。`gemm_blocked` 保持 tile 内的 `i-k-j` 顺序，并在计时区域内清零 C；这使实验同时反映真实 blocked kernel 的初始化成本。

## 运行方法

```bash
./scripts/run_blocking.sh
```

默认比较：

```text
i-k-j, block size 16, 32, 64, 128
```

快速检查：

```bash
GEMM_SIZES=64,128 GEMM_REPEATS=2 GEMM_BLOCK_SIZES=16,32,64 ./scripts/run_blocking.sh /tmp/gemm-blocking
```

也可以直接运行单个 tile：

```bash
./build/release/gemm_benchmark --kernel blocked --block-size 64
```

## 结果

正式结果见 [`results/phase1/blocking/summary.md`](../../results/phase1/blocking/summary.md)。本机测试的四个 tile size 均没有超过 unblocked `i-k-j`。在测试范围内，block size 128 最接近 baseline，但 1024³ 仍慢约 1.29×。

## 解释边界

`./scripts/generate_codegen_reports.sh` 生成的 GCC 报告显示，blocked kernel 的最内层 j 循环已经使用 16-byte XMM packed 向量，并保留标量尾部；因此 blocked 变慢不是因为它完全没有 SIMD。不过当前仍没有 cache miss 硬件计数器，不能把变慢唯一归因于某一种 cache 层级或某一类循环开销。下一步应加入 matrix packing，并配合 `perf stat` 和更细粒度的 tile 工作集分析。

生成代码证据位于 `artifacts/phase1/codegen-o3/blocked/`。审计未启用 `-march=native`、`-mavx2` 或 `-mfma`，也没有观察到 YMM、ZMM 或 FMA 指令。

## 与后续阶段的连接

Phase 1.4 说明单纯增加 tile 不一定自动获得性能；高性能 GEMM 通常还需要 packing、微内核和 SIMD。下一阶段将把 packing 作为独立变量，再研究它如何改善 B 的布局和连续加载。
