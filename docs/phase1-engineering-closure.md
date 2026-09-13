# Phase 1.8：Engineering Closure

## 目标

Phase 1.1–1.7 已完成 CPU GEMM 的算法与性能实验。Phase 1.8 只整理工程结构、补充
回归保护并准备阶段边界，不引入新的优化算法，也不修改已经记录的 Phase 1 实验数据。

Phase 1 在 Phase 1.8 全部完成前保持开放。Phase 1.8.6 完成最终检查后，才创建
phase1-complete annotated tag，保存 Phase 1 的源码、脚本、文档和结果。

## 重构不变量

Phase 1.8 必须保持：

- gemm_naive 到 gemm_avx2_4x8_parallel 的公共接口与计算循环；
- CLI kernel 名称、参数语义、帮助文本和错误约束；
- CSV header、字段含义和记录顺序；
- warm-up、计时、packing、输出与 FP64 verification 边界；
- CMake presets、实验脚本和已有 results/phase1/ 内容；
- 编译优化参数以及专用 AVX2/FMA function target attribute。

结构重构后的新 benchmark 不能覆盖旧实验数据。历史结论继续引用产生数据的原始 Git
revision。

## 阶段划分

| 子阶段 | 内容 | 状态 |
|---|---|---|
| Phase 1.8.1 | 集中管理 KernelKind、metadata 与执行分派 | 完成 |
| Phase 1.8.2 | 拆分 benchmark 组件 | 完成 |
| Phase 1.8.3 | 重命名核心 CMake target | 完成 |
| Phase 1.8.4 | 分离 portable 与 AVX2 源文件 | 待开始 |
| Phase 1.8.5 | 测试、格式与回归整理 | 待开始 |
| Phase 1.8.6 | 最终检查并建立 phase1-complete tag | 待开始 |

## Phase 1.8.1：Kernel Registry

### 问题

此前 benchmark 使用 std::string 表示 kernel，并在 CLI validation、packing 判断、
ISA、microkernel shape、loop order、block size 和执行分派中重复比较字符串。新增 kernel
需要同步修改多个位置，最后一个普通 else 还会把遗漏的种类隐式当成 avx2-mt。

### 方案

新增内部 KernelKind 枚举和 KernelDescriptor：

~~~cpp
enum class KernelKind {
    Naive,
    Ikj,
    Blocked,
    Packed,
    Micro,
    Avx2,
    Avx2Multithreaded,
};
~~~

每个 descriptor 集中保存：

- CLI name；
- loop order；
- target ISA；
- microkernel shape；
- 是否需要 PackedB；
- 是否使用 block size；
- 是否支持多个 worker thread。

parse_kernel_kind() 只在 CLI 边界把字符串转换为枚举。程序内部保存 KernelKind，
元数据通过 kernel_descriptor() 查询，执行通过穷举 switch 完成。这样未知字符串、
无效枚举和遗漏的执行分支都会显式失败。

### 文件

- src/benchmark/kernel_registry.hpp：枚举、descriptor 和内部接口；
- src/benchmark/kernel_registry.cpp：唯一 metadata table 与执行分派；
- tests/test_kernel_registry.cpp：名称 round-trip、能力字段和非法输入测试；
- src/benchmark/benchmark.cpp：只消费 registry，不再保存重复 kernel metadata。

registry 位于 src/benchmark/ 而非公共 include/gemm/，因为它描述的是 benchmark
CLI 和实验元数据，不是 GEMM 计算库的公共 API。

### 验证

- Release 构建无 warning；
- 原有 GEMM correctness tests 通过；
- 新增 kernel registry tests 通过；
- 七种 kernel 的 CLI smoke test 全部 verify: PASS；
- --help 的 kernel 顺序与内容保持不变；
- CSV header 保持逐字符一致；
- 非 avx2-mt kernel 仍拒绝 --threads > 1。

本阶段没有修改 src/kernels/，因此不重新运行或覆盖 Phase 1 performance results。

## Phase 1.8.2：Benchmark Components

### 问题

此前 `benchmark.cpp` 同时定义 CLI 数据结构、参数解析、统计公式、实验执行、
控制台格式、CSV schema 和 `main()`。这些职责共享匿名 namespace，导致参数规则和
输出格式难以单独测试，后续加入 profiler 或新结果格式时也必须修改同一个大文件。

### 方案

本阶段建立六类内部组件：

- `benchmark_types`：共享配置与结果；
- `benchmark_options`：CLI 解析和约束；
- `benchmark_statistics`：median 与 GFLOP/s；
- `benchmark_runner`：warm-up、计时、packing 和 verification；
- `benchmark_output`：控制台与 CSV；
- `benchmark_main`：顶层组合。

这些文件编译为内部 `gemm_benchmark_support` target，`gemm_benchmark` 可执行文件
只包含入口。该 target 不安装、不导出，也不改变 `include/gemm/` 中的公共接口。

### 协议保持

拆分没有把多次 kernel 调用合并成一个连续测量循环。每次测量结束后仍立即输出结果，
下一次测量才开始，因此 warm-up 次数、输出间隔、计时边界和验证位置与 Phase 1.8.1
一致。CSV 字段顺序和 CLI 文本也保持不变。

新增 `test_benchmark_options.cpp`，覆盖默认值、方阵列表、一般 M/N/K、help 文本、
kernel/thread 约束以及 verification/CSV 冲突。兼容性回归使用 Phase 1.8.1 可执行文件
逐项比较七种 kernel 的配置与验证摘要、错误文本和 CSV header。

## Phase 1.8.3：Core CMake Target

### 问题

`gemm_baseline` 最初只表示 naive baseline，但随后逐步加入 loop-order、blocking、
packing、microkernel、AVX2、多线程和 verification 实现。继续使用这个名称会让构建图
误导读者，以为优化 kernel 位于另一个 target。

### 方案

将内部静态库 target 重命名为 `gemm_core`，并同步更新 benchmark support 和
correctness tests 的链接依赖。选择 `core` 是因为该 target 不只包含 kernels，
还包含 verification 实现并导出 `include/gemm/` 头文件搜索路径。

重命名后的构建关系是：

```text
gemm_core → gemm_benchmark_support → gemm_benchmark
    └──────────────────────────────→ gemm_tests
```

这是构建系统中的语义重命名。源文件、命名空间、公共函数、可执行文件
`gemm_benchmark`、CTest 名称、编译参数和 CLI 均保持不变。新构建目录生成
`libgemm_core.a`，该文件属于未提交的构建产物。

### 验证

- CMake 配置中不再存在名为 `gemm_baseline` 的 target 或链接依赖；
- fresh Release 构建只生成 `libgemm_core.a`；
- Release、Address/Undefined Sanitizer 和 Thread Sanitizer 测试通过；
- Phase 1.8.2 与 Phase 1.8.3 的 benchmark 输出兼容；
- kernels、公共头文件、脚本与历史结果没有修改。

## 下一步

Phase 1.8.4 将把当前混合在 `gemm_microkernel.cpp` 中的 portable microkernel、
AVX2/FMA kernel 和多线程调度按实现边界拆分。公共 API 与算法循环保持不变，并通过
对象级代码生成检查确认专用 ISA 没有扩散到 generic translation unit。
