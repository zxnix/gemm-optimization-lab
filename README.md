# GEMM Optimization Lab

面向 AI Compiler 的高性能计算与编译优化研究项目。当前版本是 Phase 1 的
单线程、纯 C++17、FP32 GEMM baseline。

## 为什么先建立这个版本

GEMM 同时连接张量计算、循环变换、编译器 IR、向量指令和 CPU/GPU
存储层次。第一版刻意采用直观的 `i-j-k` 三重循环：它提供可验证、可重复的
对照组，并暴露 row-major 布局下按列读取 B 所造成的低效访存。后续每次只加入
一种优化，才能把性能变化归因到编译器选项、循环顺序、cache blocking、packing
或 SIMD。

baseline 源码保持 naive，但 benchmark 使用 Release 构建。`-O0` 主要用于调试，
不能代表合理的原生 C++ 性能。本阶段不启用 `-march=native`、`-ffast-math`、
OpenMP、手写 SIMD 或第三方矩阵库。

## Fedora 44 环境

安装最小开发工具：

```bash
sudo dnf install gcc-c++ cmake ninja-build git
```

确认环境：

```bash
g++ --version
cmake --version
ninja --version
```

推荐使用 GCC 作为第一组实验编译器；后续 LLVM 阶段再安装并对比 Clang：

```bash
sudo dnf install clang llvm
```

## 工程结构

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

`Matrix` 使用 `std::vector<float>` 管理连续 row-major 内存。计算内核支持一般的
`M×K` 与 `K×N` 矩阵，而默认 benchmark 使用 256、512 和 1024 三组方阵。

## 构建和测试

使用独立 build 目录，避免生成文件污染源码：

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
ctest --test-dir build --output-on-failure
```

如未安装 Ninja，去掉 `-G Ninja` 即可使用 CMake 默认生成器。

## 运行 benchmark

```bash
./build/gemm_benchmark
```

默认流程对每个尺寸执行一次不计时 warm-up，再正式运行 7 次。可修改次数：

```bash
./build/gemm_benchmark --repeats 5
```

程序输出每次耗时与 GFLOP/s，以及平均值、median 和正确性结果。性能计算使用：

```text
FLOPs   = 2 × M × N × K
GFLOP/s = FLOPs / time_seconds / 1e9
```

计时区域只包含 `gemm_naive`，不包含内存分配、随机初始化、输出和正确性验证。
验证器用 FP64 累加生成参考值，并同时检查绝对误差和相对误差。

## 建议记录的实验信息

每次正式实验记录：CPU 型号、cache 层级、Fedora/kernel 版本、编译器版本、完整
编译参数、矩阵尺寸、每次耗时、mean、median、GFLOP/s 和误差。可用以下命令采集
基础环境：

```bash
lscpu
uname -a
g++ --version
cmake --build build --verbose
```

首轮只建立 wall-clock 和 GFLOP/s 基线。下一阶段保持计算代码不变，比较编译器
选项并检查 LLVM IR/汇编；随后依次研究循环顺序、cache blocking、packing、SIMD
和多线程，最终把这些手工循环变换映射到 Tensor IR schedule。
