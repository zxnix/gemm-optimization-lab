# Baseline 代码走读

`Matrix` 用一个 `std::vector<float>` 拥有全部元素。逐元素访问不检查边界，因为它位于 GEMM 最内层；安全性由形状不变量和 kernel 入口检查保证。

| 循环 | 含义 |
|---|---|
| `i` | C 的行，spatial axis |
| `j` | C 的列，spatial axis |
| `k` | 点积累计方向，reduction axis |

row-major 下 `A(i,k)` 连续，而 `B(k,j)` 每次跨过 B 的一整行。这一低效访问是 baseline 特征，不能在 naive kernel 中偷偷修复。

验证器先把 FP32 输入提升为 FP64，再乘法和累加。benchmark 的矩阵分配、初始化、warm-up、统计、输出和验证都不进入正式 kernel 计时。
