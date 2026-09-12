# Phase 1.5 实验结果：Matrix Packing

## 实验环境

- 源码版本：`0ae7375f9f82114d8ec3e7c75ac6c3b68c4a3195`
- 系统：Fedora Linux 44 on WSL2，Linux 6.6.87.2
- CPU：13th Gen Intel Core i9-13905H，20 logical CPUs
- 编译器：GCC 16.1.1
- 构建：Release，`-O3 -DNDEBUG`
- 协议：packing 与 GEMM 分别 warm-up 一次并各正式运行七次；下表使用 median

所有 blocked/packed 组合使用相同输入、block size、`ii-jj-kk / i-k-j`
循环顺序、验证和 GEMM 计时边界。所有组合均为 `verify: PASS`。

## 测量结果

`packed compute` 不包含 packing；`one-shot` 是同一次样本的
`packing + compute`。Speedup 的计算方式是 `blocked time / packed compute time`，
大于 1 表示 packed compute 更快。

| Shape | Block | Blocked (ms) | Packed compute (ms) | Speedup | Packing (ms) | One-shot (ms) |
|---|---:|---:|---:|---:|---:|---:|
| 256³ | 16 | 3.077 | 3.125 | 0.985× | 0.016 | 3.141 |
| 256³ | 32 | 2.042 | 1.991 | 1.026× | 0.018 | 2.025 |
| 256³ | 64 | 2.257 | 1.898 | 1.189× | 0.014 | 1.912 |
| 256³ | 128 | 1.725 | 1.624 | 1.062× | 0.011 | 1.635 |
| 512³ | 16 | 26.108 | 25.776 | 1.013× | 0.084 | 25.854 |
| 512³ | 32 | 18.680 | 16.261 | 1.149× | 0.082 | 16.342 |
| 512³ | 64 | 24.399 | 14.992 | 1.627× | 0.081 | 15.066 |
| 512³ | 128 | 14.497 | 13.908 | 1.042× | 0.069 | 13.977 |
| 1024³ | 16 | 236.001 | 216.225 | 1.091× | 0.345 | 216.569 |
| 1024³ | 32 | 162.917 | 133.399 | 1.221× | 0.364 | 133.781 |
| 1024³ | 64 | 208.294 | 116.809 | 1.783× | 0.370 | 117.192 |
| 1024³ | 128 | 129.595 | 123.998 | 1.045× | 0.306 | 124.300 |

unblocked `i-k-j` 的 median 分别为 1.598、13.727 和 107.859 ms。每种
shape 中最好的 packed 结果分别为 packed-128、packed-128 和 packed-64：

| Shape | Best packed compute | i-k-j | Packed relative to i-k-j |
|---|---:|---:|---:|
| 256³ | 1.624 ms | 1.598 ms | 慢 1.6% |
| 512³ | 13.908 ms | 13.727 ms | 慢 1.3% |
| 1024³ | 116.809 ms | 107.859 ms | 慢 8.3% |

## 结果解释

在 12 组 matched comparisons 中，packed compute 有 11 组快于相同 block size
的原始 blocked kernel，观测到的最高 speedup 为 1.783×。这支持“tile-major B
可以改善 blocked 访问”的假设，但不能据此断言所有收益都来自某一级 cache：
当前没有硬件计数器，而且 WSL2 运行期间存在明显的频率、调度或系统负载漂移。

packing 的 median 为 0.011–0.370 ms。对这些方阵而言，`O(KN)` 数据转换远小于
`O(MNK)` GEMM，因此 one-shot 与 compute-only 很接近；对于较小 M、矩阵向量乘法
或只做很少计算的形状，该结论不一定成立。

最好的 packed 版本仍未稳定超过简单的 `i-k-j`。原因是当前 packed kernel 仍使用
普通 C++ 内层循环，没有寄存器分块和专用 SIMD 微内核。packing 改善了输入布局，
但也保留了 tile 循环、边界和索引开销。这表明 packing 是供后续微内核消费的数据
布局变换，而不是脱离 code generation 就必然加速的独立开关。

## 变异与解释边界

部分序列存在明显的运行时漂移，例如同一组 1024³ 的连续样本变化超过一般稳定
benchmark 所期望的范围。因此表中比值是当前 WSL2 开发环境的观测值，不作为
论文级 effect size。下一轮原生 Linux 实验应固定 CPU affinity 与频率，交错或
随机化 kernel 顺序，并加入硬件性能计数器。

## 结论与下一步

Phase 1.5 已建立独立的 `PackedB` 表示、packing API、边界 padding、正确性测试，
以及 compute-only/one-shot 两种成本模型。结果说明 packed layout 可显著改善部分
blocked 配置，但还没有形成稳定优于 `i-k-j` 的高性能内核。

下一步进入 Phase 1.6：设计固定尺寸 register microkernel，并显式使用 AVX2/FMA；
届时 packed tile 将为向量加载提供规则、连续的数据。
