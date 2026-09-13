# Phase 2.2：Unoptimized IR and C++ Semantic Mapping

## Background

Phase 2.1 固定了 Clang/LLVM 22.1.8，并保存 naive GEMM 的 `-O0/-O3` LLVM IR
（LLVM Intermediate Representation，LLVM 中间表示）。Phase 2.2 不改变 kernel，
而是阅读 `-O0` IR，将 C++ 语义映射到 basic block、控制流和数据访问。

选择 `-O0` 是因为它保留了函数调用、局部变量和循环骨架，适合第一次建立映射；这不表示
`-O0` 更接近 CPU 的实际高性能执行。LLVM IR 也不是 C++ 源码的逐行翻译，其中包含
C++ ABI（Application Binary Interface，应用二进制接口）、异常处理和标准库实现细节。

## Research Question

1. C++ 的参数检查和短路逻辑如何变成 basic block 与 branch？
2. `i-j-k` 三重循环如何变成循环头、循环体、递增块和回边？
3. FP32 归约、row-major 索引和 `std::vector<float>` 数据访问如何在 IR 中表达？
4. 为什么 `-O0` IR 仍属于 SSA，却没有 `phi` instruction？

## Hypothesis

在带 `optnone` 的 `-O0` IR 中，局部变量将主要保存在 `alloca` stack slot，通过
`load/store` 更新；每个 C++ `for` 循环将形成 condition、body、increment 和 exit
基本块。Matrix accessor 不会被内联，因此 row-major 地址计算位于独立函数中。

## Fixed Input

本阶段只读取以下已提交输入：

- C++：[`src/kernels/gemm_naive.cpp`](../../src/kernels/gemm_naive.cpp)；
- O0 IR：[`llvm-ir.ll`](../../artifacts/phase2/llvm-baseline/naive/O0/llvm-ir.ll)；
- source revision：`04c6ac74cadfb1558aa4443c0f9b0555ec12f116`；
- O0 IR SHA-256：`25023ebd4c6de0342d6f16f5f70ea01c270b5d48c6b5afb6ba5f219f97d8d94f`。

没有重新编译或覆盖 Phase 2.1 IR。Phase 1 的 source、tests、results、artifacts 和
`phase1-complete` tag 也没有改变。

## Method and Reproduction

首先验证 IR，再由 LLVM `opt` 的 `dot-cfg-only` pass 生成 CFG（Control-Flow Graph，
控制流图）：

```bash
opt -passes=verify -disable-output \
  artifacts/phase2/llvm-baseline/naive/O0/llvm-ir.ll
./scripts/generate_unoptimized_ir_cfg.sh
```

`opt` 原始 DOT 使用进程内地址作为节点 ID，每次执行可能不同。脚本只将这些临时 ID
替换为 IR 中的 basic-block name，不改变节点或边，并验证 `gemm_naive` 恰好包含
20 个基本块和 24 条边。稳定产物位于：

```text
artifacts/phase2/unoptimized-ir/naive/
├── cfg.dot
└── metadata.txt
```

若已安装 Graphviz，可在本地渲染，但 SVG 不提交到仓库：

```bash
dot -Tsvg artifacts/phase2/unoptimized-ir/naive/cfg.dot -o /tmp/gemm-naive-o0-cfg.svg
```

## Semantic Mapping

### 1. Module, Data Layout and Function Boundary

IR 第 1–4 行记录 source file、target data layout 和 target triple。当前 triple 是
`x86_64-redhat-linux-gnu`，所以指针宽度、alignment 和 ABI 结论只适用于该目标。

IR 第 6–10 行将当前 `Matrix` 实例表示为两个 `i64` 字段和一个 vector 对象。该 vector
在本次 libstdc++ ABI 下包含三个指针，因此函数参数上的 `dereferenceable(40)` 与
`8 + 8 + 3 × 8 = 40` 字节一致。这是当前编译环境的布局证据，不是 C++ 标准保证。

C++ 函数：

```cpp
void gemm_naive(const Matrix& a, const Matrix& b, Matrix& c)
```

对应 IR 第 34 行：

```llvm
define dso_local void @_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_(
    ptr %a, ptr %b, ptr %c) personality ptr @__gxx_personality_v0
```

三个 C++ reference 在 opaque-pointer IR 中表现为带 `nonnull`、alignment 和
dereferenceable 属性的 `ptr`。mangled name 经过 `c++filt` 后为：

```text
gemm::gemm_naive(gemm::Matrix const&, gemm::Matrix const&, gemm::Matrix&)
```

`personality` 指定 C++ exception handling（异常处理）使用的运行时 personality
function；它不是 GEMM 数值计算的一部分。

### 2. Local Variables and Memory-Based Form

IR 第 36–47 行在 `entry` 中为参数副本、异常状态、`m/n/k_size`、`i/j/k` 和 `sum`
创建 `alloca`。对应关系如下：

| C++ entity | LLVM stack slot | IR type |
|---|---|---|
| `a`, `b`, `c` reference | `%a.addr`, `%b.addr`, `%c.addr` | `ptr` |
| `m`, `n`, `k_size` | `%m`, `%n`, `%k_size` | `i64` |
| `i`, `j`, `k` | `%i`, `%j`, `%k` | `i64` |
| `sum` | `%sum` | `float` |
| exception state | `%exn.slot`, `%ehselector.slot` | `ptr`, `i32` |

这里的 `alloca` 是当前函数局部 slot 的 IR 表达，不是为 Matrix 元素申请 heap memory。
A、B、C 的连续数据已经存在于调用方创建的 `std::vector<float>` 中。

`std::size_t` 在该 x86-64 目标上降低为 `i64`。循环比较使用 `icmp ult`，其中 `u`
表示 unsigned（无符号），与 `std::size_t` 的无符号语义一致。

### 3. Shape Check and Exception Control Flow

C++ 第 8 行由三个用 `||` 连接的维度条件组成。短路求值对应三个连续判断块：

| C++ condition | IR compare | True edge | False edge |
|---|---|---|---|
| `a.cols() != b.rows()` | `%cmp` | `if.then` | `lor.lhs.false` |
| `c.rows() != a.rows()` | `%cmp4` | `if.then` | `lor.lhs.false5` |
| `c.cols() != b.cols()` | `%cmp8` | `if.then` | `if.end` |

因此，只要任一比较为 true 就进入 `if.then`；只有三个比较均为 false 才进入正常计算。
这说明 `||` 没有降低为“先计算三个布尔值再统一判断”，而是保留了 C++ 的短路语义。

异常路径包含：

```text
if.then
  ├─ normal → invoke.cont → __cxa_throw → unreachable
  └─ unwind → lpad → free exception → eh.resume
```

`invoke` 与普通 `call` 的区别是它同时给出 normal destination 和 unwind destination。
如果 `invalid_argument` 构造成功，则 `__cxa_throw` 不返回；如果构造过程抛出异常，则
`landingpad` 接管清理并继续 unwind。这些块解释了为什么一个很短的 C++ 参数检查会
产生多条 IR 控制流边。

### 4. Dimension Values and Three Nested Loops

维度读取位于 `if.end`：`a.rows()`、`b.cols()`、`a.cols()` 的返回值依次存入
`%m`、`%n`、`%k_size`。随后 `i = 0`，控制流进入最外层循环。

三重循环的完整映射如下：

| C++ semantic | Initialization | Condition | Body | Increment | Exit |
|---|---|---|---|---|---|
| `for (i = 0; i < m; ++i)` | `if.end` | `for.cond` | `for.body` | `for.inc25` | `for.end27` |
| `for (j = 0; j < n; ++j)` | `for.body` | `for.cond13` | `for.body15` | `for.inc22` | `for.end24` |
| `for (k = 0; k < k_size; ++k)` | `for.body15` | `for.cond16` | `for.body18` | `for.inc` | `for.end` |

数字后缀如 `13`、`15`、`22` 是 Clang 生成的名称去重标记，不表示循环编号、执行次数
或优化优先级。真正的循环结构由 branch 和 back edge（回边）决定：

- `for.inc → for.cond16`：`k` loop back edge；
- `for.inc22 → for.cond13`：`j` loop back edge；
- `for.inc25 → for.cond`：`i` loop back edge。

每个 condition block 都执行 `load → icmp ult → br`。true edge 进入循环体，false
edge 进入 exit block。若 `M`、`N` 或 `K` 为零，相应 false edge 保证循环体不执行。

### 5. Inner Reduction and Output Store

C++ 的 `sum = 0.0F` 和 `k = 0` 同处 `for.body15`，说明每个新的 `(i,j)` 输出元素
都会重新初始化归约状态。inner body `for.body18` 的关键路径是：

```text
load i, k → call A(i,k) accessor → load A value
load k, j → call B(k,j) accessor → load B value
load sum  → llvm.fmuladd.f32(A, B, sum) → store sum
```

C++ 第 22 行的 `sum += a(i, k) * b(k, j)` 对应 IR 第 134–146 行。这里出现
`llvm.fmuladd.f32` 表示前端允许将该乘加表达式作为可收缩的浮点运算表达；它不是已经
使用硬件 FMA（Fused Multiply-Add，融合乘加）指令的证据。Phase 2.1 的最终 Assembly
仍使用标量 `mulss/addss`。

当 `k` condition 为 false 时，`for.end` 读取 `%sum`，调用可写的 `C(i,j)` accessor，
并执行一次 `store float`。所以每个输出元素在完成整个长度 K 的归约后才写回 C。

### 6. Row-Major Address Calculation

由于 `-O0` function 带 `noinline optnone`，`gemm_naive` 内只看到 Matrix accessor 的
`call`。真正的线性索引位于 IR 第 225–244 行的 const accessor 和第 249–268 行的
mutable accessor：

```llvm
%mul = mul i64 %row, %cols
%add = add i64 %mul, %col
```

它直接对应 row-major（行主序）公式：

```text
linear_index = row × number_of_columns + column
```

随后 `std::vector<float>::operator[]` 读取 `_M_start`，使用
`getelementptr ... float, ptr %start, i64 %linear_index` 得到元素地址。`getelementptr`
负责地址计算，本身不读取 float；真正读取元素的是调用方对返回指针执行的 `load`。

代入三个矩阵的参数后：

| Access | Linear index | k 每增加 1 时的地址变化 |
|---|---|---|
| `A(i,k)` | `i × K + k` | `+1` float，连续访问 |
| `B(k,j)` | `k × N + j` | `+N` float，stride access |
| `C(i,j)` | `i × N + j` | inner reduction 结束后写一次 |

这从 IR 地址公式解释了 Phase 1 中 naive `i-j-k` 的访问模式。它是静态访问规律，不等于
cache miss 数量；cache 行为仍需要动态硬件计数器或受控 benchmark 验证。

本次 Fedora 环境定义了 `_GLIBCXX_ASSERTIONS=1`，所以 IR 第 270–372 行中的两个
`std::vector<float>::operator[]` 还包含 bounds assertion path。该路径来自平台标准库
配置，不是 naive GEMM 算法本身；换用不同 libstdc++ 配置时可能消失。

### 7. SSA without `phi` at O0

LLVM IR 始终要求 SSA（Static Single Assignment，静态单赋值）形式：每个 `%name`
只被定义一次。但这不要求 C++ 的每个可变变量都直接成为 SSA register value。

在当前 O0 IR 中，`%i`、`%j`、`%k` 和 `%sum` 是 memory address，各次迭代通过
`load/store` 修改该地址中的内容；真正的临时值如 `%12`、`%cmp12`、`%inc26` 仍各自
只定义一次。因此整个 IR 符合 SSA，但无需使用 `phi` 合并循环不同前驱的变量值。

后续 Phase 2.3 中，`mem2reg` 类变换会把 eligible stack slot 提升为 SSA value。此时
循环头需要 `phi` 在初始值与 back-edge value 之间选择。这正是 Phase 2.1 中 O3 IR
出现 16 个 `phi`、同时 `alloca` 降为 0 的背景。

### 8. End-to-End Source Mapping

| C++ source | Main IR evidence | Meaning |
|---|---|---|
| function line 7 | IR 34–188 | ABI-lowered function and exception personality |
| shape check lines 8–10 | IR 51–91 | short-circuit branches and throw path |
| dimensions lines 12–14 | IR 93–102 | accessor calls and dimension stack slots |
| `i` loop line 17 | IR 103–114, 170–180 | outer spatial axis |
| `j` loop line 18 | IR 113–125, 164–177 | inner spatial axis |
| `sum` line 19 | IR 122–124 | one accumulator initialization per C element |
| `k` loop line 21 | IR 124–153 | reduction axis and back edge |
| multiply-add line 22 | IR 134–146 | two FP32 loads and FP32 reduction update |
| C store line 24 | IR 155–162 | one output write after reduction |
| Matrix accessor | IR 225–268 | row-major `row × cols + col` |
| vector element address | IR 270–372 | base pointer plus float element index |

## Validation

本阶段完成以下检查：

- `opt -passes=verify` 接受固定 O0 IR；
- CFG generator 验证预期的 20 个 basic block 和 24 条 edge；
- 在独立 clean checkout 的 `b092db3` revision 重复生成后，`cfg.dot` 的 SHA-256
  均为 `7a9e29caf3e20ee5bbfc7c2098ea3300baa7f2ae2a7f2423bd4f03fa09064802`；
- CFG metadata 保存 input IR hash、function name、LLVM version 和生成 pass；
- `git diff phase1-complete -- src include tests results/phase1 artifacts/phase1` 为空。

## Benchmark

本阶段没有运行性能 benchmark。原因是被测 C++ kernel、编译参数和 executable 均未
改变；Phase 2.2 的自变量是“如何观察和解释 IR”，结果是静态结构证据而非运行时间。
重复运行 Phase 1 benchmark 不会回答本阶段的 research question。

## Result

假设得到验证：

1. 三个 `||` 条件被降低为保留 short-circuit semantics 的连续 basic block；
2. 三个 C++ `for` 分别形成 condition、body、increment、exit 和 back edge；
3. O0 局部状态保存在 12 个 function-local `alloca` 中，并由 `load/store` 更新；
4. inner reduction 使用 FP32 `llvm.fmuladd.f32` 语义，但没有 vector IR，也不能据此
   声称使用硬件 FMA；
5. accessor IR 明确给出 `row × cols + col`，从而证明 A 连续、B 跨 N 个 float 访问；
6. O0 IR 仍是 SSA，只是可变 C++ 局部变量尚未从 memory form 提升为 `phi` value。

## Limitations

- 源码和 IR 行号绑定当前已提交 artifact；重新生成 IR 后需要重新审计映射。
- `-O0` 仍经过 C++ frontend lowering，并非“完全没有任何编译器处理”。
- ABI、exception handling 和 libstdc++ assertion path 具有平台相关性。
- 静态 IR 不能给出动态 instruction count、cache miss、branch miss 或执行时间。
- 本阶段只分析 naive kernel，没有分析 blocked、packed、AVX2 或 multithreaded kernel。

## Next Step

Phase 2.3 将以当前语义地图为参照，比较 O0 与 O3 的 CFG 和 value flow，并通过受控 pass
实验解释 `alloca/load/store` 如何转为 `phi`、accessor 如何被 inline、循环如何被
unroll，以及每种结构变化由哪类 optimization pass 产生。
