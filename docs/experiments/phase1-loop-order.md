# Phase 1.3：循环顺序与内存访问实验

## 研究问题

在相同的 FP32 GEMM、row-major layout、输入数据、编译器和 benchmark 协议下，`i-j-k` 与 `i-k-j` 两种循环顺序如何影响内存访问和性能？

## 实验假设

- `i-j-k` 中，A 的 `A(i,k)` 在 k 方向连续，但 B 的 `B(k,j)` 跨行访问，stride 为 `N*sizeof(float)`。
- `i-k-j` 中，固定 `i,k` 后，j 方向连续访问 B 的一整行和 C 的一整行；A 的一个元素被 j 循环复用。
- 对 row-major 矩阵而言，`i-k-j` 应具有更好的空间局部性，尤其在矩阵规模超过 cache 容量后更明显。

## 控制变量

固定以下条件，只改变循环顺序和对应的累加方式：

- 同一个 git revision；
- GCC Release/`-O3`；
- 相同随机种子、矩阵规模和 FP32 数据；
- 单线程、row-major、一次 warm-up、七次正式测量；
- 相同 FP64 reference 验证；
- 不使用 `-march=native`、`-ffast-math`、SIMD intrinsic、OpenMP 或 blocking。

`gemm_ikj` 在计时区域内先清零 C，因为 i-k-j 需要向 C 累加；这一步是该 kernel 的必要初始化成本。两种 kernel 都使用相同的 `C` 输出对象和相同的计时边界。

## 运行方法

```bash
./scripts/run_loop_order.sh
```

快速检查：

```bash
GEMM_SIZES=64,128 GEMM_REPEATS=2 ./scripts/run_loop_order.sh /tmp/gemm-loop-order
```

也可以直接选择 kernel：

```bash
./build/release/gemm_benchmark --kernel naive
./build/release/gemm_benchmark --kernel ikj
```

## 输出

- `results/phase1/loop-order/system-info.txt`：硬件、系统、编译器和 git revision；
- `results/phase1/loop-order/naive/`：`i-j-k` 原始数据和终端输出；
- `results/phase1/loop-order/ikj/`：`i-k-j` 原始数据和终端输出。

CSV 中的 `kernel` 字段明确标识循环实现，避免把不同 kernel 的记录混在一起。

## 与后续阶段的连接

该实验把性能变化从“编译器优化级别”转移到“源代码循环结构和访存顺序”。结果将用于下一阶段 cache blocking：先理解单个 tile 内的连续访问，再控制 tile 的工作集大小，使其适配不同层级 cache。
