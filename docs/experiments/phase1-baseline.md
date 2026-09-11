# Phase 1.0：FP32 naive GEMM baseline

## 问题与假设

研究最直接的 row-major、单线程 `i-j-k` GEMM 是否正确以及性能如何随尺寸变化。假设 `B(k,j)` 的 stride 为 `N*sizeof(float)`，N 增大时局部性恶化、性能下降。

## 环境（2026-09-11）

```text
Fedora Linux 44 / WSL2, kernel 6.6.87.2
Intel Core i9-13905H, 20 logical CPUs
L1d 480 KiB, L2 12.5 MiB, L3 24 MiB
GCC 16.1.1, CMake 4.3.0, Ninja 1.13.2
Release, single thread, warm-up 1, measured runs 7
```

| N | Mean | Median | Median GFLOP/s | 验证 |
|---:|---:|---:|---:|---|
| 256 | 9.205 ms | 9.166 ms | 3.661 | PASS |
| 512 | 95.164 ms | 92.215 ms | 2.911 | PASS |
| 1024 | 2308.244 ms | 2296.089 ms | 0.935 | PASS |

最大绝对误差分别为 `1.672e-05`、`3.404e-05`、`6.797e-05`。结果与大 stride 假设一致，但 wall-clock 不能单独证明 Cache miss 是原因。下一步保持源码不变，比较 `-O0/-O1/-O2/-O3` 和生成的汇编，再改变循环顺序。
