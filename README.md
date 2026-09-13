# GEMM Optimization Lab

[中文](#中文) | [English](#english)

中文详解：[项目结构](docs/architecture.md) · [代码走读](docs/code-walkthrough.md) · [数值验证](docs/numerical-verification.md) · [Benchmark 方法](docs/benchmark-methodology.md) · [Phase 1 工程收尾](docs/phase1-engineering-closure.md) · [Baseline 实验](docs/experiments/phase1-baseline.md) · [编译器优化级别实验](docs/experiments/phase1-compiler-options.md) · [Cache Blocking 实验](docs/experiments/phase1-blocking.md) · [Matrix Packing 实验](docs/experiments/phase1-packing.md) · [SIMD 实验](docs/experiments/phase1-simd.md) · [多线程实验](docs/experiments/phase1-multithreading.md)

## 中文

GEMM Optimization Lab 是一个研究型系统项目，用于学习面向 AI 编译器系统的高性能计算与编译优化技术。

## Motivation

现代 AI 工作负载高度依赖矩阵计算。本项目研究编译器变换和硬件感知优化如何影响 GEMM 性能，并通过工程实验理解从 C++ 与张量程序到编译器 IR、机器指令以及 CPU/GPU 执行的完整路径。

## Current Milestone

**Phase 1.8 — Engineering Closure（1.8.2 已完成）**

项目当前包含单线程 FP32 GEMM baseline、GCC 优化级别实验、循环顺序、cache blocking、B matrix packing、portable 4×8 microkernel、显式 AVX2/FMA 4×8 microkernel，以及沿 M 维静态分区的 C++17 多线程 kernel，不依赖任何第三方矩阵库。

### Scope

- 稠密矩阵乘法：`C = A × B`
- 支持一般的 `M×K` 与 `K×N` 矩阵形状
- FP32 连续内存和 row-major 布局
- 单线程 `i-j-k` 基础循环顺序
- 使用 FP64 累加的参考实现进行正确性验证
- 默认一次不计时 warm-up 和七次正式测量
- 输出单次耗时、平均值、中位数和 GFLOP/s
- 测试手工结果、随机非方阵和非法维度
- 比较 GCC 优化级别及其生成的汇编代码
- 比较 row-major 下不同循环顺序的内存访问行为
- 比较 cache blocking 的不同 tile size
- 分离测量 B matrix packing、packed compute 与 one-shot 成本
- 比较 portable register microkernel 与显式 AVX2/FMA
- 测量 1、2、4、8、10、20 个 worker thread 的 speedup 与并行效率
- 使用 Linux `perf` 采集可用的硬件性能计数器
- 使用强类型 `KernelKind` 和集中式 descriptor 管理 benchmark kernel
- 将 benchmark 拆分为参数、运行、统计、输出和入口组件

除专用 AVX2 kernel 外，其余实现使用普通 C++ 循环。AVX2/FMA 仅应用于带运行时能力检查的目标函数；项目仍不启用全局 `-march=native`、`-ffast-math` 或 OpenMP，也不使用 BLAS、MKL、Eigen 等外部矩阵库。

## Roadmap

- [x] Phase 1.1：Naive GEMM baseline 与可复现 benchmark
- [x] Phase 1.2：编译器优化级别分析
- [x] Phase 1.3：循环顺序与内存访问分析
- [x] Phase 1.4：Cache blocking 分析
- [x] Phase 1.5：Matrix packing
- [x] Phase 1.6：SIMD/AVX 向量化
- [x] Phase 1.7：多线程与硬件性能计数器
- [ ] Phase 1.8：工程收尾与阶段冻结
  - [x] Phase 1.8.1：集中管理 KernelKind、metadata 与执行分派
  - [x] Phase 1.8.2：拆分 benchmark 组件
  - [ ] Phase 1.8.3：重命名核心 CMake target
  - [ ] Phase 1.8.4：分离 portable 与 AVX2 源文件
  - [ ] Phase 1.8.5：测试、格式与回归整理
  - [ ] Phase 1.8.6：Phase 1 最终冻结
- [ ] Phase 2：LLVM IR 与机器指令分析
- [ ] Phase 3：Tensor IR 与调度
- [ ] Phase 4：CUDA/GPU 后端优化
- [ ] Phase 5：硬件感知自动调优

## Development Environment

### Operating System

- Fedora Linux 44 on WSL2，用于开发阶段实验
- 后续使用原生 Linux 进行受控、论文级性能测量

### Toolchain

- C++17
- CMake 与 Ninja
- Git 与 GitHub Actions

### Compiler Toolchain

- GCC：baseline 与优化级别实验
- Clang/LLVM：编译器分析阶段

### Target Hardware

当前目标：

- x86-64 CPU

未来目标：

- 支持 CUDA 的 GPU
- NPU 或其他 AI 加速器后端

在 Fedora 中安装开发工具：

```bash
sudo dnf install gcc-c++ cmake ninja-build git
sudo dnf install clang llvm
sudo dnf install perf libtsan
```

## Project Structure

```text
.
├── .github/workflows/       # 持续集成
├── artifacts/phase1/        # 生成的汇编和编译器报告
├── docs/
│   └── experiments/         # 实验设计与方法
├── include/gemm/            # Matrix、GEMM 和验证接口
├── results/phase1/          # 原始 benchmark 数据与结果总结
├── scripts/                 # 可重复执行的实验脚本
├── src/
│   ├── kernels/             # GEMM kernels
│   ├── verification/        # 数值正确性验证
│   └── benchmark/           # 参数、运行、统计、输出与程序入口
├── tests/                   # 正确性与错误处理测试
├── AGENTS.md                # 项目协作与科研规范
├── CMakeLists.txt
├── CMakePresets.json        # 本地与 CI 共享的构建配置
└── README.md
```

`Matrix` 使用连续的 `std::vector<float>` 按 row-major 布局保存元素。kernel 支持一般矩阵形状，默认 benchmark 使用 256、512 和 1024 三种方阵规模。

## Build and Test

```bash
cmake --preset release
cmake --build --preset release
ctest --preset release
```

需要排查内存错误或未定义行为时，使用同一套 Debug Sanitizer 配置：

```bash
cmake --preset debug-sanitizers
cmake --build --preset debug-sanitizers
ctest --preset debug-sanitizers
```

检查多线程数据竞争时使用独立的 ThreadSanitizer 配置：

```bash
cmake --preset debug-thread-sanitizer
cmake --build --preset debug-thread-sanitizer
ctest --preset debug-thread-sanitizer
```

`CMakePresets.json` 是提交到仓库的共享配置，本地和 GitHub Actions 使用相同参数。个人机器专用配置可写入不提交的 `CMakeUserPresets.json`。

## Run the Benchmark

```bash
./build/release/gemm_benchmark
./build/release/gemm_benchmark --repeats 5
./build/release/gemm_benchmark --sizes 128,256,512 --csv results.csv
./build/release/gemm_benchmark --m 128 --n 3072 --k 768
./build/release/gemm_benchmark --kernel ikj --sizes 128,256,512
./build/release/gemm_benchmark --kernel blocked --block-size 64 --sizes 128,256,512
./build/release/gemm_benchmark --kernel packed --block-size 64 --sizes 128,256,512
./build/release/gemm_benchmark --kernel micro --block-size 64 --sizes 128,256,512
./build/release/gemm_benchmark --kernel avx2 --block-size 64 --sizes 128,256,512
./build/release/gemm_benchmark --kernel avx2-mt --threads 4 --block-size 128
```

运行可复现实验：

```bash
./scripts/run_compiler_options.sh
./scripts/run_packing.sh
./scripts/run_simd.sh
./scripts/run_multithreading.sh
```

生成 `i-k-j`、blocked、packed 与 microkernel 的 O3 Assembly 和向量化报告：

```bash
./scripts/generate_codegen_reports.sh
```

性能计算方式：

```text
FLOPs   = 2 × M × N × K
GFLOP/s = FLOPs / time_seconds / 1e9
```

计时区域只包含当前选择的 GEMM kernel。内存分配、随机初始化、终端输出和 FP64 正确性验证均不计入内核运行时间。packed kernel 将 packing 与 compute-only 分开测量，并额外报告 one-shot 的 `packing + compute` 成本。

## Reproducibility

所有 benchmark 结果都应能够在固定的软硬件环境中复现。每个正式实验记录 Git revision、CPU 与 cache 信息、操作系统与内核、编译器版本及参数、矩阵形状、每次耗时、平均值、中位数、GFLOP/s 和数值误差。WSL2 测量只作为开发基线，不直接作为论文级硬件结论。

## Results

Phase 1.1–1.7 的结果位于 [`results/phase1`](results/phase1)。Phase 1.7 的多线程
AVX2/FMA kernel 在 1024³ 上从 64.671 GFLOP/s（1 thread）提升到
272.810 GFLOP/s（20 threads），speedup 为 4.218×。256³ 的最佳点则是 2 threads，
说明线程创建与调度开销会限制小矩阵。完整数据见 [Phase 1.2](results/phase1/compiler-options/summary.md)、[Phase 1.3](results/phase1/loop-order/summary.md)、[Phase 1.4](results/phase1/blocking/summary.md)、[Phase 1.5](results/phase1/packing/summary.md)、[Phase 1.6](results/phase1/simd/summary.md) 和 [Phase 1.7](results/phase1/multithreading/summary.md)。

## Continuous Integration

GitHub Actions 自动验证：

- 使用 CMake 完成 Release 和 Debug 构建
- 单元测试和基本正确性检查
- Debug 模式下的 AddressSanitizer 与 UndefinedBehaviorSanitizer 检查
- 独立 ThreadSanitizer 构建中的数据竞争检查

---

## English

GEMM Optimization Lab is a research-oriented systems project for studying high-performance computing and compiler optimization techniques toward AI compiler systems.

## Motivation

Modern AI workloads rely heavily on matrix computation. This project studies how compiler transformations and hardware-aware optimization affect GEMM performance, building a practical foundation for understanding the path from C++ and tensor programs to compiler IR, machine instructions, and CPU/GPU execution.

## Current Milestone

**Phase 1.8 — Engineering Closure (1.8.2 completed)**

The project currently provides a single-threaded FP32 GEMM baseline, controlled GCC optimization-level and loop-order experiments, cache blocking, B matrix packing, portable and explicit AVX2/FMA 4×8 microkernels, and a C++17 multithreaded kernel that statically partitions the M dimension. No third-party matrix library is used.

### Scope

- Dense matrix multiplication: `C = A × B`
- General `M×K` by `K×N` matrix shapes
- Contiguous FP32 storage with row-major layout
- Canonical single-threaded `i-j-k` loop order
- FP64-accumulated reference implementation for correctness verification
- One untimed warm-up followed by seven measured runs by default
- Per-run time, mean, median, and GFLOP/s reporting
- Unit tests for known, random rectangular, and invalid-dimension cases
- Controlled comparison of GCC optimization levels and generated assembly
- Comparison of row-major memory-access behavior across loop orders
- Comparison of cache-blocking tile sizes
- Separate measurement of B packing, packed compute, and one-shot cost
- Comparison of a portable register microkernel with explicit AVX2/FMA
- Speedup and parallel-efficiency measurements across 1, 2, 4, 8, 10, and 20 workers
- Linux `perf` hardware-counter collection when available
- Strongly typed `KernelKind` and centralized benchmark-kernel descriptors
- Benchmark components separated into options, runner, statistics, output, and entry point

All implementations except the dedicated AVX2 kernel use ordinary C++ loops. AVX2/FMA is limited to a target-specific function guarded by a runtime capability check. The project still does not enable global `-march=native`, `-ffast-math`, or OpenMP, and does not use BLAS, MKL, Eigen, or other external matrix libraries.

## Roadmap

- [x] Phase 1.1: Naive GEMM baseline and reproducible benchmark
- [x] Phase 1.2: Compiler optimization-level analysis
- [x] Phase 1.3: Loop-order and memory-access analysis
- [x] Phase 1.4: Cache-blocking analysis
- [x] Phase 1.5: Matrix packing
- [x] Phase 1.6: SIMD/AVX vectorization
- [x] Phase 1.7: Multithreading and hardware performance counters
- [ ] Phase 1.8: Engineering closure and phase freeze
  - [x] Phase 1.8.1: Centralize KernelKind, metadata, and dispatch
  - [x] Phase 1.8.2: Split benchmark components
  - [ ] Phase 1.8.3: Rename the core CMake target
  - [ ] Phase 1.8.4: Separate portable and AVX2 source files
  - [ ] Phase 1.8.5: Test, formatting, and regression cleanup
  - [ ] Phase 1.8.6: Final Phase 1 freeze
- [ ] Phase 2: LLVM IR and machine-instruction analysis
- [ ] Phase 3: Tensor IR and scheduling
- [ ] Phase 4: CUDA/GPU backend optimization
- [ ] Phase 5: Hardware-aware automatic tuning

## Development Environment

### Operating System

- Fedora Linux 44 on WSL2 for development experiments
- Native Linux planned for controlled, publication-quality measurements

### Toolchain

- C++17
- CMake and Ninja
- Git and GitHub Actions

### Compiler Toolchain

- GCC for baseline and optimization-level experiments
- Clang/LLVM for the compiler-analysis phase

### Target Hardware

Current target:

- x86-64 CPU

Future targets:

- CUDA-capable GPU
- NPU or other AI accelerator backend

Install the development tools on Fedora:

```bash
sudo dnf install gcc-c++ cmake ninja-build git
sudo dnf install clang llvm
sudo dnf install perf libtsan
```

## Project Structure

```text
.
├── .github/workflows/       # Continuous integration
├── artifacts/phase1/        # Generated assembly and compiler reports
├── docs/
│   └── experiments/         # Experiment designs and methodology
├── include/gemm/            # Matrix, GEMM, and verification interfaces
├── results/phase1/          # Raw benchmark data and result summaries
├── scripts/                 # Reproducible experiment automation
├── src/
│   ├── kernels/             # GEMM kernels
│   ├── verification/        # Numerical verification
│   └── benchmark/           # Options, runner, statistics, output, and entry point
├── tests/                   # Correctness and error-handling tests
├── AGENTS.md                # Project collaboration and research rules
├── CMakeLists.txt
├── CMakePresets.json        # Shared local and CI build configurations
└── README.md
```

`Matrix` stores elements in a contiguous `std::vector<float>` using row-major layout. The kernel supports general matrix shapes, while the default benchmark uses square matrices of sizes 256, 512, and 1024.

## Build and Test

```bash
cmake --preset release
cmake --build --preset release
ctest --preset release
```

Use the shared Debug Sanitizer configuration to diagnose memory errors and undefined behavior:

```bash
cmake --preset debug-sanitizers
cmake --build --preset debug-sanitizers
ctest --preset debug-sanitizers
```

Use the separate ThreadSanitizer configuration to check for data races:

```bash
cmake --preset debug-thread-sanitizer
cmake --build --preset debug-thread-sanitizer
ctest --preset debug-thread-sanitizer
```

`CMakePresets.json` is committed as the shared configuration used by local development and GitHub Actions. Machine-specific settings may be placed in the untracked `CMakeUserPresets.json`.

## Run the Benchmark

```bash
./build/release/gemm_benchmark
./build/release/gemm_benchmark --repeats 5
./build/release/gemm_benchmark --sizes 128,256,512 --csv results.csv
./build/release/gemm_benchmark --m 128 --n 3072 --k 768
./build/release/gemm_benchmark --kernel ikj --sizes 128,256,512
./build/release/gemm_benchmark --kernel blocked --block-size 64 --sizes 128,256,512
./build/release/gemm_benchmark --kernel packed --block-size 64 --sizes 128,256,512
./build/release/gemm_benchmark --kernel micro --block-size 64 --sizes 128,256,512
./build/release/gemm_benchmark --kernel avx2 --block-size 64 --sizes 128,256,512
./build/release/gemm_benchmark --kernel avx2-mt --threads 4 --block-size 128
```

Run the reproducible experiments:

```bash
./scripts/run_compiler_options.sh
./scripts/run_packing.sh
./scripts/run_simd.sh
./scripts/run_multithreading.sh
```

Generate O3 assembly and vectorization reports for the `i-k-j`, blocked, packed, and microkernel implementations:

```bash
./scripts/generate_codegen_reports.sh
```

Performance is reported using:

```text
FLOPs   = 2 × M × N × K
GFLOP/s = FLOPs / time_seconds / 1e9
```

Only the selected GEMM kernel is timed. Memory allocation, random initialization, terminal output, and FP64 correctness verification are outside the timed region. The packed kernel measures packing and compute-only separately and also reports the one-shot `packing + compute` cost.

## Reproducibility

All benchmark results should be reproducible under a fixed hardware and software environment. Each formal experiment records the Git revision, CPU and cache information, operating system and kernel, compiler version and flags, matrix shapes, individual run times, mean, median, GFLOP/s, and numerical error. WSL2 measurements are treated as development baselines rather than publication-quality hardware results.

## Results

Results for Phases 1.1–1.7 are available in [`results/phase1`](results/phase1). On 1024³,
the Phase 1.7 multithreaded AVX2/FMA kernel improves from 64.671 GFLOP/s with one thread to
272.810 GFLOP/s with 20 threads, a 4.218× speedup. The best 256³ result uses only two threads,
showing that thread lifecycle and scheduling overhead dominate small matrices. See the summaries for [Phase 1.2](results/phase1/compiler-options/summary.md), [Phase 1.3](results/phase1/loop-order/summary.md), [Phase 1.4](results/phase1/blocking/summary.md), [Phase 1.5](results/phase1/packing/summary.md), [Phase 1.6](results/phase1/simd/summary.md), and [Phase 1.7](results/phase1/multithreading/summary.md).

## Continuous Integration

GitHub Actions automatically verifies:

- Release and Debug builds with CMake
- Unit tests and correctness checks
- AddressSanitizer and UndefinedBehaviorSanitizer checks in Debug mode
- A separate ThreadSanitizer build for data-race detection
