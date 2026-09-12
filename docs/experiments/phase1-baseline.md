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
| 256 | 14.652 ms | 14.389 ms | 2.332 | PASS |
| 512 | 134.666 ms | 132.557 ms | 2.025 | PASS |
| 1024 | 3587.841 ms | 3469.235 ms | 0.619 | PASS |

最大绝对误差分别为 `1.251e-05`、`2.868e-05`、`7.589e-05`。原始数据保存在 `results/phase1/baseline/`。结果与大 stride 假设一致，但 wall-clock 不能单独证明 Cache miss 是原因。下一步保持源码不变，比较 `-O0/-O1/-O2/-O3` 和生成的汇编，再改变循环顺序。
