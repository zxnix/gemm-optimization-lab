# GEMM Optimization Lab

[中文](#中文) | [English](#english)

中文详解：[项目结构](docs/architecture.md) · [代码走读](docs/code-walkthrough.md) · [数值验证](docs/numerical-verification.md) · [Benchmark 方法](docs/benchmark-methodology.md) · [Baseline 实验](docs/experiments/phase1-baseline.md) · [编译器优化级别实验](docs/experiments/phase1-compiler-options.md)

## 中文

GEMM Optimization Lab 是一个研究型系统项目，用于学习面向 AI 编译器系统的高性能计算与编译优化技术。

## Motivation

现代 AI 工作负载高度依赖矩阵计算。本项目研究编译器变换和硬件感知优化如何影响 GEMM 性能，并通过工程实验理解从 C++ 与张量程序到编译器 IR、机器指令以及 CPU/GPU 执行的完整路径。

## Current Milestone

**Phase 1.2 — 编译器优化分析（已完成）**

项目当前包含一个使用标准 C++17 实现的单线程 FP32 GEMM baseline，以及 GCC `-O0/-O1/-O2/-O3` 控制变量实验，不依赖任何第三方矩阵库。

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

源码层面的算法仍保持 naive。当前实验不启用 `-march=native`、`-ffast-math`、OpenMP、手写 SIMD，也不使用 BLAS、MKL、Eigen 等外部矩阵库。

## Roadmap

- [x] Phase 1.1：Naive GEMM baseline 与可复现 benchmark
- [x] Phase 1.2：编译器优化级别分析
- [ ] Phase 1.3：循环顺序与内存访问分析
- [ ] Phase 1.4：Cache blocking 与矩阵 packing
- [ ] Phase 1.5：SIMD/AVX 向量化
- [ ] Phase 1.6：多线程与硬件性能计数器
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
│   └── benchmark/           # benchmark 程序
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

`CMakePresets.json` 是提交到仓库的共享配置，本地和 GitHub Actions 使用相同参数。个人机器专用配置可写入不提交的 `CMakeUserPresets.json`。

## Run the Benchmark

```bash
./build/release/gemm_benchmark
./build/release/gemm_benchmark --repeats 5
./build/release/gemm_benchmark --sizes 128,256,512 --csv results.csv
./build/release/gemm_benchmark --m 128 --n 3072 --k 768
```

运行编译器优化级别控制实验：

```bash
./scripts/run_compiler_options.sh
```

性能计算方式：

```text
FLOPs   = 2 × M × N × K
GFLOP/s = FLOPs / time_seconds / 1e9
```

计时区域只包含 `gemm_naive`。内存分配、随机初始化、终端输出和 FP64 正确性验证均不计入内核运行时间。

## Reproducibility

所有 benchmark 结果都应能够在固定的软硬件环境中复现。每个正式实验记录 Git revision、CPU 与 cache 信息、操作系统与内核、编译器版本及参数、矩阵形状、每次耗时、平均值、中位数、GFLOP/s 和数值误差。WSL2 测量只作为开发基线，不直接作为论文级硬件结论。

## Results

Phase 1.1 baseline 和 Phase 1.2 编译选项结果位于 [`results/phase1`](results/phase1)。在当前 Fedora 44 WSL2 环境中，GCC `-O3` 相比 `-O0` 在 256³、512³ 和 1024³ GEMM 上分别约快 21.20×、18.17× 和 5.15×。完整数据和解释见 [Phase 1.2 结果总结](results/phase1/compiler-options/summary.md)。

## Continuous Integration

GitHub Actions 自动验证：

- 使用 CMake 完成 Release 和 Debug 构建
- 单元测试和基本正确性检查
- Debug 模式下的 AddressSanitizer 与 UndefinedBehaviorSanitizer 检查

---

## English

GEMM Optimization Lab is a research-oriented systems project for studying high-performance computing and compiler optimization techniques toward AI compiler systems.

## Motivation

Modern AI workloads rely heavily on matrix computation. This project studies how compiler transformations and hardware-aware optimization affect GEMM performance, building a practical foundation for understanding the path from C++ and tensor programs to compiler IR, machine instructions, and CPU/GPU execution.

## Current Milestone

**Phase 1.2 — Compiler Optimization Analysis (completed)**

The project currently provides a single-threaded FP32 GEMM baseline in standard C++17 and a controlled GCC `-O0/-O1/-O2/-O3` experiment. No third-party matrix library is used.

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

The source-level algorithm remains naive. The current experiments do not use `-march=native`, `-ffast-math`, OpenMP, handwritten SIMD, BLAS, MKL, Eigen, or other external matrix libraries.

## Roadmap

- [x] Phase 1.1: Naive GEMM baseline and reproducible benchmark
- [x] Phase 1.2: Compiler optimization-level analysis
- [ ] Phase 1.3: Loop-order and memory-access analysis
- [ ] Phase 1.4: Cache blocking and matrix packing
- [ ] Phase 1.5: SIMD/AVX vectorization
- [ ] Phase 1.6: Multithreading and hardware performance counters
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
│   └── benchmark/           # Benchmark program
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

`CMakePresets.json` is committed as the shared configuration used by local development and GitHub Actions. Machine-specific settings may be placed in the untracked `CMakeUserPresets.json`.

## Run the Benchmark

```bash
./build/release/gemm_benchmark
./build/release/gemm_benchmark --repeats 5
./build/release/gemm_benchmark --sizes 128,256,512 --csv results.csv
./build/release/gemm_benchmark --m 128 --n 3072 --k 768
```

Run the controlled compiler optimization-level experiment:

```bash
./scripts/run_compiler_options.sh
```

Performance is reported using:

```text
FLOPs   = 2 × M × N × K
GFLOP/s = FLOPs / time_seconds / 1e9
```

Only `gemm_naive` is timed. Memory allocation, random initialization, terminal output, and FP64 correctness verification are outside the timed region.

## Reproducibility

All benchmark results should be reproducible under a fixed hardware and software environment. Each formal experiment records the Git revision, CPU and cache information, operating system and kernel, compiler version and flags, matrix shapes, individual run times, mean, median, GFLOP/s, and numerical error. WSL2 measurements are treated as development baselines rather than publication-quality hardware results.

## Results

The Phase 1.1 baseline and Phase 1.2 compiler-option results are available in [`results/phase1`](results/phase1). On the current Fedora 44 WSL2 environment, GCC `-O3` is approximately 21.20×, 18.17×, and 5.15× faster than `-O0` for 256³, 512³, and 1024³ GEMM respectively. See the [Phase 1.2 result summary](results/phase1/compiler-options/summary.md) for the complete data and interpretation.

## Continuous Integration

GitHub Actions automatically verifies:

- Release and Debug builds with CMake
- Unit tests and correctness checks
- AddressSanitizer and UndefinedBehaviorSanitizer checks in Debug mode
