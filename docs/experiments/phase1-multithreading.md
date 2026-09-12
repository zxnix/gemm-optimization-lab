# Phase 1.7：Multithreading 与 Hardware Performance Counters

## 研究问题

在保持 Phase 1.6 的 PackedB、4×8 register microkernel、AVX2/FMA 和 block size
不变时，增加 CPU worker thread 能获得怎样的加速比与并行效率？性能何时停止近似线性
增长，限制因素来自线程管理、调度、cache、内存带宽还是硬件资源共享？

## 背景原理

GEMM 的每个输出元素满足：

~~~text
C[i,j] = sum(A[i,k] * B[k,j], k=0..K-1)
~~~

不同输出行之间没有数据依赖。因此可以沿 M 维把 C 切成多个行区间：所有线程只读
共享 A 和 PackedB，每个线程只写自己的 C 行。只要行区间不重叠，就不需要 mutex，
也不存在对 C 元素的数据竞争。

本阶段把 M 维划分单位设为一个 4-row micro-tile，以避免两个线程共同计算同一个
4×8 微块。若 M 方向共有 G 个 micro-row group、请求 T 个线程，则实际 worker 数为
`min(G, T)`；不能平均分配的 group 依次交给前面的 worker。

## 设计方案

新增 `gemm_avx2_4x8_parallel` 和 benchmark kernel `avx2-mt`。实现使用 C++17
`std::thread`，不引入 OpenMP 或线程池，从而先观察最直接的线程创建、执行与 join
模型。一次 kernel 调用的计时包含 worker 创建和 join；因此小矩阵可能因为工作量不足
而比单线程更慢。这是本阶段要测量的真实开销，不在计时外隐藏。

选择 M 维静态连续分区的原因：

- 工作量容易估算，每个输出行都执行近似相同的 N×K 计算；
- 线程写入连续的 row-major C 行，局部性明确；
- A 和 PackedB 只读共享，无需复制和同步；
- 便于把线程级并行与 Phase 1.6 的向量级并行分离。

替代方案包括按 N 分区、二维 tile 调度、动态任务队列和常驻线程池。二维调度对非方阵
和 NUMA 更灵活，线程池能摊薄生命周期成本，但都会同时引入新的实验变量，留待后续。

## 正确性与并发安全

测试使用 19×13 与 13×17 的非方阵，覆盖 M/N/K 边界、三个 worker 的不均匀分区、
线程请求数超过 micro-row group 数，以及零线程参数拒绝。FP32 结果继续使用同一个
FP64 reference 验证。

项目增加独立 ThreadSanitizer 配置：

~~~bash
cmake --preset debug-thread-sanitizer
cmake --build --preset debug-thread-sanitizer
ctest --preset debug-thread-sanitizer
~~~

ThreadSanitizer 与 AddressSanitizer 不能同时启用，所以使用独立 preset。它用于发现
数据竞争，不用于 benchmark。

## 实验假设

- 512³ 和 1024³ 将随线程数增加而加速，256³ 更容易被线程创建和调度开销限制；
- speedup 不会无限线性增长，因为 worker 会共享 cache、内存带宽和执行资源；
- 超过可见物理核心数量后，SMT sibling 线程的边际收益会下降，甚至可能退化；
- WSL2 的虚拟 CPU 拓扑和宿主调度会增加波动，因此结果只表示开发环境趋势。

## 控制变量

- 同一个 git revision、GCC Release/`-O3`；
- 相同输入、PackedB layout、4×8 AVX2/FMA microkernel 与 block size 128；
- 只改变请求的线程数：1、2、4、8、10、20；
- 相同的一次 warm-up、七次正式运行和 FP64 verification；
- 不固定 CPU affinity，不使用 OpenMP、BLAS、`-march=native` 或 `-ffast-math`。

线程数 1 直接执行完整 M 区间而不创建 worker thread，是多线程实现的严格对照。

## 评价指标

对线程数 T，使用同一 shape 的 median 计算：

~~~text
speedup(T)    = median_time(1) / median_time(T)
efficiency(T) = speedup(T) / T
~~~

GFLOP/s 仍按 `2MNK / time` 计算。效率下降不自动等于实现错误，它可能来自串行部分、
线程生命周期、负载不均、cache/带宽竞争、SMT 资源共享、迁移或降频。Amdahl's law
说明任意串行部分都会限制最大 speedup。

## Hardware Performance Counters

实验脚本在 `perf` 可用且内核允许访问时额外采集：

- `cycles` 与 `instructions`：计算 IPC=`instructions/cycles`；
- `cache-references` 与 `cache-misses`：计算 cache miss ratio；
- `branches` 与 `branch-misses`：观察控制流开销；
- `task-clock`、`context-switches`、`cpu-migrations`：观察并行占用和调度噪声。

IPC 不是 FLOP/s：一条 AVX2 FMA 可以表示多个浮点操作，不同指令的工作量也不同。
硬件计数器用于解释时间结果，不能替代 wall-clock benchmark。

Linux `perf stat` 默认统计整个进程，而非源码中的计时区间。计数器 workload 因此先由
ctest 和正式 benchmark 完成正确性验证，再使用 `--skip-verification` 跳过昂贵的 FP64
reference，并重复执行 50 次 kernel，使初始化、packing、一次 warm-up 和输出占比降低。
这些计数器仍是 kernel-dominated process-level 数据，不应声称为严格的 kernel-only
计数。精确区间测量可在后续使用 `perf_event_open` 或受控 profiler marker。

脚本会分别探测 hardware 与 software event。若 hardware PMU 不可用但 software event
可用，仍采集后者；能力状态写入 `hardware-counters/status.txt`，保留“不可获得”
这一实验事实，而不会把缺失值伪造成零。

## 运行方法

~~~bash
./scripts/run_multithreading.sh
~~~

快速检查：

~~~bash
GEMM_SIZES=256 GEMM_REPEATS=2 GEMM_THREAD_COUNTS=1,2,4 \
    GEMM_COUNTER_KERNEL_REPEATS=5 GEMM_PERF_REPEATS=1 \
    ./scripts/run_multithreading.sh /tmp/gemm-multithreading
~~~

单独运行：

~~~bash
./build/release/gemm_benchmark \
    --kernel avx2-mt --threads 4 --block-size 128 --sizes 256,512,1024
~~~

## 计时边界

普通 benchmark 的计时区间包括线程创建、AVX2/FMA 计算和 join；不包括矩阵分配、
随机初始化、B packing、终端输出和 FP64 verification。packing 继续单独测量，并报告
one-shot `packing + compute` 成本。

## 结果

正式结果见 [`results/phase1/multithreading/summary.md`](../../results/phase1/multithreading/summary.md)。
256³ 在 2 threads 达到最佳 105.555 GFLOP/s（1.561×）；512³ 在 20 threads 达到
214.423 GFLOP/s（3.333×）；1024³ 在 20 threads 达到 272.810 GFLOP/s（4.218×）。
小矩阵在线程生命周期成本下很快退化，而较大矩阵能更充分摊薄开销。

WSL2 不支持 cycles、instructions 和 cache 等 hardware PMU events，因此本轮没有 IPC
或 cache miss ratio；可用的 software counters 已被记录。硬件计数器部分必须在原生
Linux 上复现后才能形成硬件层结论。

## 解释边界

本阶段不使用线程池、CPU affinity、NUMA placement、first-touch、固定频率或原生 Linux。
WSL2 暴露的 core/SMT 拓扑可能与物理混合架构细节不同；线程数与“物理核心数”的关系
只能按当前 guest 可见拓扑解释。正式硬件结论必须在受控原生 Linux 上复现。

## 与后续阶段的连接

多线程 M 维分区对应 Tensor Compiler 中 spatial axis 的 parallel scheduling；4×8
microkernel 对应 vectorize/unroll；PackedB 对应 layout transformation。Phase 2 将继续
分析这些调度在 LLVM IR、函数 target attribute 和机器指令中的表示。更后面的 Tensor
IR 阶段会把同样的 split、tile、parallel、vectorize 变换从手写 C++ 提升为调度原语。
