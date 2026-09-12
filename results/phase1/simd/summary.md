# Phase 1.6 实验结果：Register Microkernel 与 AVX2/FMA

## 实验环境

- 源码版本：`1de3b1f`
- 系统：Fedora Linux 44 on WSL2，Linux 6.6.87.2
- CPU：13th Gen Intel Core i9-13905H，AVX2=true，FMA=true
- 编译器：GCC 16.1.1
- 构建：Release，`-O3 -DNDEBUG`
- 协议：packing 与 GEMM 分别 warm-up 一次并各正式运行七次；下表使用 median

所有结果均为单线程 FP32，使用相同输入和 FP64 reference。所有组合均为
`verify: PASS`。

## 测量结果

表中时间为不包含 packing 的 compute-only median：

| Kernel | Block | 256³ ms | 256³ GFLOP/s | 512³ ms | 512³ GFLOP/s | 1024³ ms | 1024³ GFLOP/s |
|---|---:|---:|---:|---:|---:|---:|---:|
| `i-k-j` | — | 2.231 | 15.037 | 18.533 | 14.484 | 142.004 | 15.123 |
| packed | 64 | 1.896 | 17.694 | 15.457 | 17.366 | 123.429 | 17.399 |
| portable 4×8 | 64 | 2.141 | 15.674 | 16.991 | 15.799 | 124.963 | 17.185 |
| AVX2/FMA 4×8 | 64 | 0.594 | 56.511 | 5.043 | 53.234 | 45.931 | 46.755 |
| packed | 128 | 1.582 | 21.214 | 13.071 | 20.537 | 110.151 | 19.496 |
| portable 4×8 | 128 | 1.612 | 20.816 | 13.351 | 20.106 | 112.431 | 19.100 |
| AVX2/FMA 4×8 | 128 | 0.601 | 55.873 | 4.658 | 57.630 | 40.203 | 53.416 |

每个 shape 的最佳 AVX2 结果及 speedup：

| Shape | Best AVX2 | vs `i-k-j` | vs matched packed | vs matched portable 4×8 |
|---|---:|---:|---:|---:|
| 256³, block 64 | 0.594 ms | 3.758× | 3.194× | 3.605× |
| 512³, block 128 | 4.658 ms | 3.979× | 2.806× | 2.866× |
| 1024³, block 128 | 40.203 ms | 3.532× | 2.740× | 2.797× |

最佳 AVX2 组合的 one-shot median 分别为 0.607、4.725 和 40.530 ms；对应
effective performance 为 55.310、56.808 和 52.985 GFLOP/s。packing 相对
compute-only 的时间约为 2.2%、1.4% 和 0.8%。

## 假设检验

portable 4×8 没有超过相同 block size 的普通 packed kernel，因此“仅改变为
microkernel schedule 就会加速”的假设在当前实现中不成立。编译器把 portable
累加循环自动向量化为 16-byte XMM，但生成代码仍在 stack memory 中反复读写
accumulator array；源码中的固定数组并不保证所有部分和长期驻留寄存器。

显式 AVX2/FMA 假设得到支持。4 个 YMM accumulator、一个复用的 B 向量以及 4 个
broadcast/FMA 明确表达了寄存器数据流，避免依赖编译器从动态边界循环中推导这一
结构。三个尺寸上的最佳结果约为 53–58 GFLOP/s。

## 数值行为

AVX2/FMA 路径的 max absolute error 为 1.212e-05、2.932e-05 和 7.589e-05，
均通过联合绝对/相对容限。FMA 只进行一次舍入，因此结果不要求与
`mul + add` 路径逐 bit 相同。部分 max relative error 较大是因为参考值接近零；
`failure_count=0` 表明联合容限仍满足。

## 解释边界

这是 WSL2 上的一轮开发测量，不代表硬件峰值或论文级结果。当前没有固定 core、
锁定频率或使用硬件计数器。4×8 也只是第一个微内核，没有探索 MR×NR、A packing、
alignment、prefetch 和多级 cache blocking 的联合参数。

## 结论与下一步

Phase 1.6 已证明 packed layout、register blocking 与显式 ISA lowering 可以组合成
明显快于基础循环的专用 CPU kernel。它也展示了一个关键编译器事实：高级循环结构
“看起来可向量化”不等于编译器一定生成理想的寄存器数据流。

下一步 Phase 1.7 将研究线程级并行和硬件性能计数器；之后进入 Phase 2，对 portable
与 AVX2 实现的 LLVM IR、函数 target attribute 和最终机器指令进行系统比较。
