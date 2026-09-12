# Phase 1.2：编译器优化级别实验

## 研究问题

同一份 naive FP32 GEMM 源码，在 GCC `-O0`、`-O1`、`-O2` 和 `-O3` 下会产生怎样的性能差异？这些差异能否从编译命令、汇编和向量化报告中得到解释？

## 实验假设

- `-O0` 基本保留源码结构，循环中的索引计算、函数调用和内存访问开销较大。
- `-O1/-O2` 会逐步启用内联、循环简化、公共子表达式消除等优化。
- `-O3` 允许更积极的循环变换和向量化，但 naive `i-j-k` 对矩阵 B 的跨行访问仍然受 cache locality 限制，因此编译选项无法消除算法访存瓶颈。

## 控制变量

固定以下条件，只改变优化级别：

- 同一个 git revision；
- 同一份 `gemm_naive` 单线程 `i-j-k` kernel；
- FP32、row-major、相同随机种子与矩阵规模；
- 一次 warm-up、七次计时、相同验证方法；
- 不使用 `-march=native`、`-ffast-math`、BLAS、SIMD intrinsic 或多线程。

这里的 `Release` 负责关闭调试断言；脚本显式覆盖其优化参数，从而保证每个构建目录只对应一个 `-O` 级别。

## 运行方法

```bash
./scripts/run_compiler_options.sh
```

快速检查可缩小规模和次数：

```bash
GEMM_SIZES=64,128 GEMM_REPEATS=2 ./scripts/run_compiler_options.sh /tmp/gemm-results /tmp/gemm-artifacts
```

## 输出

- `results/phase1/compiler-options/system-info.txt`：硬件、系统、编译器与 git revision；
- `results/phase1/compiler-options/O*/raw-results.csv`：逐次时间、GFLOP/s、误差和优化级别；
- `results/phase1/compiler-options/O*/console.txt`：完整终端输出；
- `artifacts/phase1/compiler-options/O*/compile_commands.json`：实际编译命令；
- `artifacts/phase1/compiler-options/O*/gemm_naive.s`：GCC 生成的汇编；
- `artifacts/phase1/compiler-options/O*/vectorization.txt`：向量化诊断；
- `artifacts/phase1/compiler-options/O*/binary-size.txt`：可执行文件段大小。

## 解释边界

WSL2 中的调度、宿主机负载和功耗状态会造成波动，因此本结果是开发基线，不直接作为论文级硬件结论。比较时优先看 median，并同时检查七次运行的离散程度。性能变化必须结合实际编译命令和生成代码解释，不能仅凭 `-O3` 名称推断。

## 本机结果

正式结果、速度比和生成代码分析见 [`results/phase1/compiler-options/summary.md`](../../results/phase1/compiler-options/summary.md)。所有组合均通过 FP64 reference 验证。

## 与下一阶段的连接

该实验建立“源程序 → 编译选项 → 机器代码 → 性能”的证据链。下一步将固定优化级别，改变循环顺序，再进入 cache blocking；Phase 2 则会对同一 kernel 的 LLVM IR 和机器指令进行系统分析。
