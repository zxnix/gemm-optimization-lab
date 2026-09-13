# Phase 2.1：LLVM Toolchain and Naive IR Baseline

## 背景

Phase 1 通过 benchmark 和 Assembly 证明不同 C++ 结构会产生不同性能。Phase 2.1
固定 Clang/LLVM 工具链，并以 `gemm_naive.cpp` 为第一个 translation unit，建立：

```text
C++ source
    ↓ clang++ -emit-llvm
LLVM IR
    ↓ opt -passes=verify
verified LLVM IR
    ↓ llc
x86-64 Assembly
    ↓ clang++ / llvm-objdump
object disassembly
```

LLVM IR（LLVM Intermediate Representation，LLVM 中间表示）位于高级 C++ 语义和
具体机器指令之间。后续 optimization pass、向量化和 target lowering 都以这一层为核心。

## Research Question

本阶段回答三个问题：

1. Fedora 44 中的 Clang 与 LLVM command-line tools 是否版本一致且完整？
2. 不修改 naive kernel 时，能否稳定生成 `-O0` 与 `-O3` IR 和机器代码证据？
3. 两个优化级别的 IR 在规模和基本指令构成上是否已经表现出结构差异？

本阶段不解释每个 pass，也不声称性能提升。详细 IR 阅读属于 Phase 2.2。

## Method

输入固定为 `src/kernels/gemm_naive.cpp`，公共参数为：

```text
-std=c++17 -Iinclude -DNDEBUG -fno-discard-value-names -g0
```

唯一主要变量是 `-O0` 与 `-O3`。两组都不使用 `-march=native`、`-mavx2`、
`-mfma` 或 `-ffast-math`，因此不会把当前机器的全部 ISA 能力隐式写入结果。

`-fno-discard-value-names` 保留较易阅读的 SSA（Static Single Assignment，静态单赋值）
名称；`-g0` 排除 debug metadata，降低无关差异。正常的 `-O0` IR 保留 Clang 添加的
`optnone` attribute，不伪装成已经运行过优化 pass 的 IR。

## Reproduction

完整项目的 Clang 构建：

```bash
cmake --preset clang-release
cmake --build --preset clang-release
ctest --preset clang-release
```

生成 Phase 2.1 文本证据：

```bash
./scripts/generate_llvm_baseline.sh
```

脚本要求 clean worktree，使 metadata 中的 Git commit 唯一对应输入源码。临时 object
写入 ignored build directory；仓库只保存文本 IR、Assembly、disassembly、命令和统计。

## Output Layout

```text
artifacts/phase2/llvm-baseline/
├── toolchain/
│   └── metadata.txt
└── naive/
    ├── O0/
    │   ├── llvm-ir.ll
    │   ├── assembly.s
    │   ├── object-disassembly.txt
    │   ├── commands.txt
    │   └── ir-stats.txt
    └── O3/
        └── ...
```

## Validation

完成条件：

- Clang 与 LLVM tools 的 major version 一致；
- `clang-release` 构建与全部 CTest 通过；
- `opt -passes=verify` 接受两份 IR；
- `llc` 能从两份 IR 生成 x86-64 Assembly；
- object disassembly 包含 `gemm::gemm_naive`；
- 生成目录不包含 object、bitcode 或 executable；
- Phase 1 的 source、results、artifacts 和 tag 不变。

## Result

### Environment

- source revision：`04c6ac74cadfb1558aa4443c0f9b0555ec12f116`；
- operating system：Fedora Linux 44 on WSL2，Linux 6.6.87.2；
- architecture：x86-64；
- target triple：`x86_64-redhat-linux-gnu`；
- Clang 与 LLVM：22.1.8；
- source：`src/kernels/gemm_naive.cpp`。

Clang、`opt`、`llc`、`llvm-dis`、`llvm-diff`、`llvm-objdump` 和
`llvm-mca` 的 major version 一致。完整元数据保存在
`artifacts/phase2/llvm-baseline/toolchain/metadata.txt`。

### IR Statistics

| Metric | `-O0` | `-O3` |
|---|---:|---:|
| IR lines | 397 | 295 |
| `alloca` | 26 | 0 |
| `load` | 58 | 19 |
| `store` | 31 | 1 |
| `phi` | 0 | 16 |
| `getelementptr` | 16 | 29 |
| `llvm.fmuladd.f32` call sites | 1 | 5 |
| `<N x float>` occurrences | 0 | 0 |

这里的计数是静态文本计数，不代表运行时动态执行次数。`getelementptr` 数量增加也不表示
`-O3` 更慢；优化后 Matrix accessor 被内联，更多地址表达式直接暴露在当前 function 中。

### Evidence

1. `-O0` function 带有 `noinline optnone` attribute。循环变量与累加器保存在
   `alloca` 对应的 stack slot 中，因此没有 `phi`。
2. `-O3` 删除了全部 26 个 `alloca`，显著减少显式 `load/store`，并使用 16 个
   `phi` 表达循环 induction value 和 FP32 reduction value。这是 memory-based IR
   转为 SSA value flow 的直接证据。
3. `-O3` 中出现 5 个标量 `llvm.fmuladd.f32` call site，对应按 4 展开的主体和
   一个 remainder 路径。IR 中没有 vector-of-float 类型，因此本次 Clang 22.1.8
   没有把 naive reduction 变成向量 IR。
4. 两个优化级别的 target features 都只声明 generic x86-64 的 SSE/SSE2 能力，不包含
   FMA。虽然 IR 使用 `llvm.fmuladd.f32` 表示可收缩的乘加语义，最终 Assembly 仍是
   标量 `mulss/addss`；IR intrinsic 不保证后端一定选择硬件 FMA 指令。
5. `clang-release` 完整构建通过 6/6 CTest；两份 IR 都通过
   `opt -passes=verify`，并成功由 `llc` 生成 Assembly。object disassembly 均包含
   `gemm::gemm_naive`。

本阶段没有运行新的性能 benchmark，因为唯一目标是建立编译器表示基线。Phase 1 的
source、tests、results、artifacts 与 `phase1-complete` tag 均未修改。

### Limitations

当前统计只能说明 IR 结构发生变化，尚未把每个 basic block、`phi` 和地址计算映射回
具体 C++ 循环，也没有识别负责这些变化的 optimization pass。以上工作留给 Phase 2.2
和 Phase 2.3。

## Next Step

Phase 2.2 将从 `-O0` IR 开始，逐项建立 C++ 循环、basic block、branch、`alloca`、
`load/store`、`getelementptr` 和浮点运算之间的对应关系。
