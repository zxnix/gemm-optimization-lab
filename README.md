# GEMM Optimization Lab

[English](#english) | [中文](#中文)

## English

GEMM Optimization Lab is a research-oriented systems project for studying high-performance computing and compiler optimization for AI compilers. The current milestone is a single-threaded FP32 GEMM baseline written in standard C++17 without third-party matrix libraries.

### Current scope

- Dense matrix multiplication: `C = A × B`
- General `M×K` by `K×N` matrix shapes
- Contiguous FP32 storage with row-major layout
- Canonical single-threaded `i-j-k` loop order
- FP64-accumulated reference implementation for correctness verification
- One untimed warm-up followed by seven measured runs by default
- Per-run time, mean, median, and GFLOP/s reporting
- Unit tests for known, random rectangular, and invalid-dimension cases

The benchmark uses a Release build while keeping the source-level algorithm naive. This milestone does not enable `-march=native`, `-ffast-math`, OpenMP, handwritten SIMD, BLAS, MKL, Eigen, or other external matrix libraries.

### Fedora 44 environment

Install and check the required tools:

```bash
sudo dnf install gcc-c++ cmake ninja-build git
g++ --version
cmake --version
ninja --version
```

GCC is used for the initial experiments. Clang and LLVM can be installed for the later compiler-analysis phase:

```bash
sudo dnf install clang llvm
```

### Project structure

```text
.
├── CMakeLists.txt
├── include/gemm/
│   ├── gemm.hpp
│   ├── matrix.hpp
│   └── verification.hpp
├── src/
│   ├── gemm_naive.cpp
│   ├── main.cpp
│   └── verification.cpp
└── tests/
    └── test_gemm.cpp
```

`Matrix` stores elements in a contiguous `std::vector<float>` using row-major layout. The kernel supports general matrix shapes, while the default benchmark uses square matrices of sizes 256, 512, and 1024.

### Build and test

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
ctest --test-dir build --output-on-failure
```

If Ninja is unavailable, omit `-G Ninja` to use CMake's default generator.

### Run the benchmark

```bash
./build/gemm_benchmark
./build/gemm_benchmark --repeats 5
```

Performance is reported using:

```text
FLOPs   = 2 × M × N × K
GFLOP/s = FLOPs / time_seconds / 1e9
```

Only `gemm_naive` is timed. Memory allocation, random initialization, terminal output, and FP64 correctness verification are outside the timed region.

### Experiment records

For reproducible measurements, record the CPU model, cache hierarchy, Fedora and kernel versions, compiler version and flags, matrix shape, individual run times, mean, median, GFLOP/s, and numerical error.

Later milestones will compare compiler options and generated LLVM IR/assembly, then introduce loop reordering, cache blocking, packing, SIMD, multithreading, Tensor IR scheduling, and CPU/GPU backends.

---

## 中文

GEMM Optimization Lab 是一个面向 AI Compiler 的高性能计算与编译优化研究项目。当前里程碑是使用标准 C++17 编写的单线程 FP32 GEMM baseline，不依赖任何第三方矩阵库。

### 当前范围

- 稠密矩阵乘法：`C = A × B`
- 支持一般的 `M×K` 与 `K×N` 矩阵形状
- FP32 连续内存和 row-major 布局
- 单线程 `i-j-k` 基础循环顺序
- 使用 FP64 累加的参考实现进行正确性验证
- 默认一次不计时 warm-up 和七次正式测量
- 输出单次耗时、平均值、中位数和 GFLOP/s
- 测试手工结果、随机非方阵和非法维度

benchmark 使用 Release 构建，但源码算法保持 naive。本阶段不启用 `-march=native`、`-ffast-math`、OpenMP、手写 SIMD，也不使用 BLAS、MKL、Eigen 等外部矩阵库。

### Fedora 44 环境

```bash
sudo dnf install gcc-c++ cmake ninja-build git
g++ --version
cmake --version
ninja --version
```

初期实验使用 GCC。后续编译器分析阶段可安装 Clang 和 LLVM：

```bash
sudo dnf install clang llvm
```

### 构建和测试

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
ctest --test-dir build --output-on-failure
```

如果没有 Ninja，可去掉 `-G Ninja`，使用 CMake 默认生成器。

### 运行 benchmark

```bash
./build/gemm_benchmark
./build/gemm_benchmark --repeats 5
```

```text
FLOPs   = 2 × M × N × K
GFLOP/s = FLOPs / time_seconds / 1e9
```

计时区域只包含 `gemm_naive`。内存分配、随机初始化、终端输出和 FP64 正确性验证均不计入内核运行时间。

### 实验记录

为保证实验可复现，应记录 CPU 型号、cache 层级、Fedora 和 kernel 版本、编译器版本及参数、矩阵形状、每次耗时、平均值、中位数、GFLOP/s 和数值误差。

后续阶段将依次研究编译选项与 LLVM IR/汇编、循环顺序、cache blocking、packing、SIMD、多线程、Tensor IR 调度以及 CPU/GPU 后端。
