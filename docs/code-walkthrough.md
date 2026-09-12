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

## Verification 与 Benchmark

验证器先把 FP32 输入提升为 FP64，再乘法和累加。benchmark 的矩阵分配、初始化、warm-up、统计、输出和验证都不进入正式 kernel 计时。
