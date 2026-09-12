# Phase 1.5：Matrix Packing 实验

## 研究问题

在保持 blocked kernel 的 tile 大小和循环顺序不变时，把 row-major B 转换为
tile-major packed layout，能否降低 tile 内跨 B 行访问的地址跳跃并提高 GEMM 性能？
packing 本身的时间和额外空间是否会抵消计算阶段的收益？

## 背景原理

gemm_blocked 的最内层 j 循环已经连续读取 B，但完成一行的 N tile 后，下一次
k 迭代需要在原始 row-major B 中跨过约一整行的 leading dimension。packing
把参与计算的 B[kk:kk+B, jj:jj+B] 复制到连续的 B×B tile 中，使一个 tile
的所有行物理相邻。

packed B 的元素地址为：

~~~text
tile_offset =
    ((k / block_size) * ceil(N / block_size) + (j / block_size))
    * block_size²

inner_offset =
    (k % block_size) * block_size + (j % block_size)
~~~

边界 tile 补零，因此 packed buffer 占用：

~~~text
ceil(K/B) × ceil(N/B) × B² × sizeof(float)
~~~

空间可能略大于原始 B。这种转换不改变数学结果，只改变物理布局。

## 实验假设

- compute-only：packed B 可能减少 B panel 内的地址跨度，让 cache line 和硬件预取
  行为更稳定；
- one-shot：如果 B 只使用一次，packing 的复制成本可能抵消甚至超过计算收益；
- reused B：如果同一个 B 用于多次 GEMM，packing 成本可以摊薄；
- 当前尚无寄存器微内核和手写 SIMD，因此 packing 也可能没有带来提升。这同样是
  有效结果，而不是实现失败。

## 控制变量

blocked-B 与 packed-B 固定：

- 同一个 git revision、GCC Release/-O3；
- 相同的 ii-jj-kk / i-k-j 循环顺序；
- 相同 block size、输入、矩阵规模和 FP64 verification；
- FP32、row-major 逻辑矩阵、单线程；
- 不使用手写 SIMD、OpenMP、-march=native 或第三方矩阵库。

两者的主要变量只有 B 的物理布局。i-k-j 继续作为 unblocked baseline。

## 计时边界

packed benchmark 分开测量两个阶段：

~~~text
PackedB workspace 分配                 不计时
packing warm-up 1 次                   不计时
正式 packing 7 次                      单独记录
GEMM warm-up 1 次                      不计时
正式 GEMM 7 次                         只记录 compute-only
FP64 verification 与输出               不计时
~~~

报告同时给出：

- compute-only：B 已经预打包并可重复使用；
- one-shot：每次 GEMM 都需要先 packing，时间为 packing + kernel；
- packing 的单次、mean 和 median。

## 运行方法

~~~bash
./scripts/run_packing.sh
~~~

默认比较 i-k-j，以及 block size 16、32、64、128 下成对的 blocked 与 packed
kernel。快速检查：

~~~bash
GEMM_SIZES=64,128 GEMM_REPEATS=2 GEMM_BLOCK_SIZES=32,64 \
    ./scripts/run_packing.sh /tmp/gemm-packing
~~~

单独运行：

~~~bash
./build/release/gemm_benchmark --kernel packed --block-size 64
~~~

## 结果

正式结果见 [`results/phase1/packing/summary.md`](../../results/phase1/packing/summary.md)。
在当前 WSL2 测量中，packed compute 在 12 组 matched comparisons 中有 11 组快于
相同 block size 的 blocked kernel，最高观测速率为 1.783×；但每种 shape 中最好的
packed 版本仍比 unblocked `i-k-j` 慢 1.3%–8.3%。packing 的 median 为
0.011–0.370 ms，因此本次方阵的 one-shot 结果与 compute-only 很接近。

## 生成代码证据

`./scripts/generate_codegen_reports.sh` 生成的 GCC 报告显示，packed kernel
最内层 j 循环被自动向量化为 16-byte vectors，unroll factor 为 4；Assembly
包含 `mulps/addps` 和标量 remainder 的 `mulss/addss`，没有 YMM、ZMM 或 FMA。
blocked 对照的同一层循环也使用 16-byte XMM packed 向量，因此性能差异不能解释为
“packed 使用 SIMD，而 blocked 完全没有 SIMD”。证据位于
`artifacts/phase1/codegen-o3/packed/`。

## 解释边界

WSL2 测量用于工程趋势，不作为论文级硬件结论。没有硬件性能计数器时，不能仅凭
耗时断言某级 cache miss 一定减少。若 packing 只有在未来 SIMD 微内核中才产生
明显收益，应把它记录为 layout 与 code generation 需要协同设计的证据。

## 与后续阶段的连接

Tensor Compiler 通常通过 layout transformation、tiling 和 bufferization 生成类似
packing 的数据变换。Phase 1.5 将显式建立“逻辑张量不变、物理布局改变”的概念，
为 Phase 1.6 的 SIMD 微内核以及后续 Tensor IR layout/schedule 学习建立接口。
