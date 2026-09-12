# Phase 1.3 实验结果：循环顺序与内存访问

## 实验环境

- 源码版本：`84158fabd88303374a2d6e89fd9b98bb64d0b494`
- 系统：Fedora Linux 44 on WSL2，Linux 6.6.87.2
- CPU：13th Gen Intel Core i9-13905H，20 logical CPUs
- 编译器：GCC 16.1.1
- 构建：Release，`-O3 -DNDEBUG`
- 协议：一次 warm-up，七次正式运行；下表使用 median

`i-j-k` 和 `i-k-j` 在同一个可执行文件中运行，使用相同随机种子、矩阵形状、验证方法和计时边界。所有组合均为 `verify: PASS`。

## 测量结果

| 循环顺序 | 256³ median (ms) | 256³ GFLOP/s | 512³ median (ms) | 512³ GFLOP/s | 1024³ median (ms) | 1024³ GFLOP/s |
|---|---:|---:|---:|---:|---:|---:|
| `i-j-k` | 14.598 | 2.299 | 134.579 | 1.995 | 3438.528 | 0.625 |
| `i-k-j` | 1.859 | 18.054 | 15.813 | 16.976 | 138.663 | 15.487 |

以 `i-j-k` 为基准，`i-k-j` 的 median 加速比为：

| 规模 | 加速比 |
|---|---:|
| 256³ | 7.853× |
| 512³ | 8.511× |
| 1024³ | 24.798× |

## 访存解释

当前矩阵使用 row-major layout，元素地址为：

```text
address(row, col) = base + (row × N + col) × sizeof(float)
```

在 `i-j-k` 中，固定 `i,j`、递增 `k`：

```cpp
c(i, j) += a(i, k) * b(k, j);
```

- A 沿行方向访问，地址连续；
- B 的 `j` 固定、`k` 递增，跨行访问；
- B 的访问 stride 为 `N*sizeof(float)`；
- 当 N 较大时，B 的空间局部性很差。

在 `i-k-j` 中，固定 `i,k`、递增 `j`：

```cpp
const float a_value = a(i, k);
c(i, j) += a_value * b(k, j);
```

- A 的一个元素被 j 循环复用；
- B 的一整行连续访问；
- C 的一整行连续访问；
- 更符合 row-major 的空间局部性。

因此这次性能提升主要来自访存顺序和 cache locality 的改善，而不是增加了浮点运算吞吐。

## 实现边界

`i-k-j` 必须先将 C 清零，然后再进行累加；该清零过程包含在 `gemm_ikj` 的计时区域内。虽然它引入了额外的 `O(MN)` 写入，但 GEMM 主体仍为 `O(MNK)`，并且这是该循环结构实现覆盖式 C 输出所需要的初始化。

当前结果来自 WSL2，可能受到宿主机调度和频率变化影响。正式比较以同一轮实验中的 paired median 为主，不把本次 naive 数值直接与之前独立运行的 Phase 1.2 数值作绝对比较。

## 结论与下一步

Phase 1.3 证明：对于 row-major GEMM，仅改变循环顺序就能显著改变内存访问行为和性能。下一步 Phase 1.4 将固定较好的 `i-k-j` 结构，引入 cache blocking，研究 tile 尺寸和不同 cache 层级之间的关系。
