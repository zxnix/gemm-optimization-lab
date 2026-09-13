# Phase 1：CPU GEMM Optimization 总结

## 阶段目标

Phase 1 以 GEMM（General Matrix Multiplication，通用矩阵乘法）为实验对象，建立从
普通 C++17 三重循环到专用 CPU kernel 的完整优化链。重点不是制作通用矩阵库，而是用
可运行、可验证和可复现的实验理解：

```text
C++ 计算结构
    ↓
编译器优化与代码生成
    ↓
数据布局、Cache 与寄存器复用
    ↓
SIMD 指令与线程级并行
    ↓
CPU 实际执行性能
```

矩阵统一采用连续 FP32（32-bit Floating Point，32 位浮点数）row-major 存储，支持
一般的 `M×K · K×N` 形状。所有 kernel 共用 FP64（64-bit Floating Point，64 位
浮点数）累加的 reference、联合绝对/相对误差判定和同一套 benchmark 协议。

## 完成的研究链

| 阶段 | 主要变量 | 主要结论 |
|---|---|---|
| Phase 1.1 | `i-j-k` baseline | 建立连续存储、正确性验证和可复现计时基线 |
| Phase 1.2 | GCC 优化级别 | `-O3` 相对 `-O0` 消除抽象开销并改变生成代码 |
| Phase 1.3 | 循环顺序 | `i-k-j` 改善 row-major 下 B/C 的连续访问 |
| Phase 1.4 | Cache blocking | 当前普通 C++ blocking 的控制成本高于额外复用收益 |
| Phase 1.5 | B matrix packing | packing 改善多数 matched blocked 配置，但不是独立加速开关 |
| Phase 1.6 | register blocking 与 AVX2/FMA | 显式表达向量寄存器数据流后形成稳定的单线程提升 |
| Phase 1.7 | M 维线程分区 | 大矩阵可摊薄线程成本，小矩阵的最佳线程数更少 |
| Phase 1.8 | 工程收尾 | 固化接口、测试、ISA 边界、实验数据和阶段标签 |

AVX2（Advanced Vector Extensions 2，第二代高级向量扩展）负责 256-bit 向量运算，
FMA（Fused Multiply-Add，融合乘加）把乘法和加法表达为一条融合运算。SIMD
（Single Instruction, Multiple Data，单指令多数据）优化只存在于专用 translation
unit；项目没有全局启用 `-mavx2`、`-mfma` 或 `-march=native`。

## 关键实验结果

以下数字来自 Fedora Linux 44 on WSL2（Windows Subsystem for Linux 2，适用于
Linux 的 Windows 子系统第 2 版）的开发环境。各阶段可能来自不同运行轮次，因此只在
各自实验内部比较 matched median，不能把跨阶段数字直接连乘为端到端加速比。

- Phase 1.1 的 naive `i-j-k` 在 1024³ 上达到 0.619 GFLOP/s。
- Phase 1.2 中，GCC `-O3` 相对 `-O0` 在 256³、512³、1024³ 上分别快
  21.20×、18.17×、5.15×；生成代码证据显示内联、展开和有限自动向量化。
- Phase 1.3 中，`i-k-j` 相对同轮 `i-j-k` 在三个规模上分别快
  7.853×、8.511×、24.798×。
- Phase 1.4 的四种 block size 均未稳定超过 `i-k-j`，说明 blocking 必须和布局、
  微内核及代码生成共同设计。
- Phase 1.5 的 12 组 matched comparison 中有 11 组 packed compute 快于同 block
  size 的 blocked kernel，最高为 1.783×；但最佳 packed 仍未超过同轮 `i-k-j`。
- Phase 1.6 的 AVX2/FMA 4×8 microkernel 在三个规模上达到约 53–58 GFLOP/s；
  1024³ 相对同轮 `i-k-j` 快 3.532×。
- Phase 1.7 的 1024³ kernel 从 1 thread 的 64.671 GFLOP/s 提升到 20 threads 的
  272.810 GFLOP/s，即 4.218×；256³ 的最佳点则是 2 threads。

所有正式记录均保留逐次样本和验证结果，完整数据位于 `results/phase1/`。编译命令、
vectorization report 和 Assembly 证据位于 `artifacts/phase1/`。

## 得到的系统认识

1. 算术表达相同不代表执行成本相同。循环顺序会改变 stride、Cache locality、编译器
   向量化机会和最终指令。
2. 编译器优化可以消除 C++ 抽象成本，但不能自动修复所有不利的数据访问模式。
3. blocking、packing 和 microkernel 是相互关联的变换；单独加入某一步可能不加速。
4. “编译器报告已向量化”不等于形成了理想寄存器数据流。必须同时查看 Assembly 和
   实测性能。
5. 并行收益取决于问题规模、线程生命周期和共享硬件资源，线程数不是越多越好。
6. 正确性验证是优化的前置条件。FMA 改变舍入路径后，结果可通过容差验证，但不要求
   与非融合路径逐 bit 相同。

## 工程冻结状态

Phase 1 冻结点由 annotated tag `phase1-complete` 标识。该标签保存：

- 七种 benchmark kernel 及其统一执行分派；
- 公共 Matrix、packing、GEMM 与 verification 接口；
- benchmark 参数、runner、statistics、output 与 CSV schema；
- 六项 CTest 回归检查和三套 CMake preset；
- Phase 1 的实验脚本、原始结果、系统信息、汇编与向量化报告；
- README、架构说明、代码走读、实验方法和各阶段总结。

最终审计结果：

- Release、AddressSanitizer/UndefinedBehaviorSanitizer 和 ThreadSanitizer 三套构建均为
  6/6 tests passed；
- source hygiene 与所有 Shell 语法检查通过；
- generic、AVX2/FMA 和 parallel scheduler 的 ISA/symbol 边界检查通过；
- Git 未跟踪 build directory、object、library 或 executable；
- `results/phase1/` 与 `artifacts/phase1/` 的历史记录未在工程收尾阶段被覆盖。

冻结不表示代码永远不能修复，而是表示后续工作不得改写 Phase 1 的历史证据。必要修复
应产生新提交；Phase 1 的可复现状态始终可通过标签检出。

## 局限

- 结果来自 WSL2，未固定 CPU affinity、频率、温度或宿主机负载。
- WSL2 未提供所需的硬件 PMU（Performance Monitoring Unit，性能监控单元）事件，
  因此不能给出可靠的 IPC（Instructions Per Cycle，每周期指令数）或 Cache miss ratio。
- 当前只有 B packing 和 4×8 AVX2 microkernel，尚未搜索 MR×NR、A packing、prefetch、
  多级 Cache tile 和 NUMA（Non-Uniform Memory Access，非一致内存访问）策略。
- 多线程实现每次调用都会创建和 join 线程，尚未使用常驻线程池。
- 这些数据是开发基线，不是论文级硬件结论；正式研究结论需要在受控原生 Linux 复现。

## 与 Phase 2 的连接

Phase 1 回答了“哪些源码与调度变换改变了性能”。Phase 2 将继续回答“编译器如何表示
并 lower 这些变换”：

```text
代表性 C++ kernel
    ↓ Clang frontend
LLVM IR（Intermediate Representation，中间表示）
    ↓ optimization passes
optimized LLVM IR
    ↓ instruction selection
x86-64 Assembly / machine instructions
```

Phase 2 首先固定 naive、`i-k-j`、portable 4×8 和 AVX2/FMA 4×8 四个代表性 kernel，
使用相同 Clang/LLVM 版本生成 `-O0` 与 `-O3` IR，并建立 source、IR、optimization
remark 和 Assembly 的逐层对应关系。Phase 1 的标签作为比较起点，不再修改其历史结果。
