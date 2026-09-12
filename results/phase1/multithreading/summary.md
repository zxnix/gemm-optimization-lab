# Phase 1.7 实验结果：Multithreading 与 Performance Counters

## 实验环境

- 源码版本：`a21fb44`
- 系统：Fedora Linux 44 on WSL2，Linux 6.6.87.2
- CPU：13th Gen Intel Core i9-13905H，guest 可见 20 logical CPU、10 core
- 编译器：GCC 16.1.1
- 构建：Release，`-O3 -DNDEBUG`
- kernel：PackedB + AVX2/FMA 4×8 microkernel，block size 128
- 协议：一次 warm-up、七次正式运行；下表使用 compute-only median

所有线程数和 shape 均为 `verify: PASS`。Release tests 与独立 ThreadSanitizer tests
均通过。

## 时间与吞吐量

| Threads | 256³ ms | 256³ GFLOP/s | 512³ ms | 512³ GFLOP/s | 1024³ ms | 1024³ GFLOP/s |
|---:|---:|---:|---:|---:|---:|---:|
| 1 | 0.496 | 67.631 | 4.172 | 64.336 | 33.207 | 64.671 |
| 2 | 0.318 | 105.555 | 2.151 | 124.819 | 19.845 | 108.212 |
| 4 | 0.404 | 82.985 | 1.356 | 197.889 | 12.679 | 169.373 |
| 8 | 0.415 | 80.873 | 1.629 | 164.827 | 9.774 | 219.707 |
| 10 | 0.456 | 73.657 | 1.313 | 204.402 | 8.769 | 244.905 |
| 20 | 0.777 | 43.205 | 1.252 | 214.423 | 7.872 | 272.810 |

## Speedup 与 Parallel Efficiency

以每个 shape 的 `threads=1` median 为基准：

| Threads | 256³ speedup | 256³ efficiency | 512³ speedup | 512³ efficiency | 1024³ speedup | 1024³ efficiency |
|---:|---:|---:|---:|---:|---:|---:|
| 1 | 1.000× | 100.0% | 1.000× | 100.0% | 1.000× | 100.0% |
| 2 | 1.561× | 78.0% | 1.940× | 97.0% | 1.673× | 83.7% |
| 4 | 1.227× | 30.7% | 3.076× | 76.9% | 2.619× | 65.5% |
| 8 | 1.196× | 14.9% | 2.562× | 32.0% | 3.397× | 42.5% |
| 10 | 1.089× | 10.9% | 3.177× | 31.8% | 3.787× | 37.9% |
| 20 | 0.639× | 3.2% | 3.333× | 16.7% | 4.218× | 21.1% |

最佳点分别为：256³ 使用 2 threads，达到 105.555 GFLOP/s 和 1.561×；512³ 使用
20 threads，达到 214.423 GFLOP/s 和 3.333×；1024³ 使用 20 threads，达到
272.810 GFLOP/s 和 4.218×。

## 假设检验

“较大矩阵更能摊薄线程开销”的假设得到支持。256³ 的单线程 kernel 只有约 0.5 ms，
每次调用创建和 join 多个 `std::thread` 后，四线程以上不再受益；20 线程甚至比单线程
慢。512³ 在 2 和 4 线程接近有效扩展，但 8 线程出现非单调下降。1024³ 的工作量更大，
从 1 到 20 线程持续加速。

扩展并不接近 20×。20 线程下 1024³ 的效率为 21.1%，说明线程共享 cache、带宽、
执行资源和功耗预算，且线程生命周期、SMT/混合核心、guest 与宿主调度均可能形成
限制。当前没有 affinity 和频率控制，512³ 的非单调结果不能被解释成固定硬件规律。

## Performance Counter 结果

Fedora `perf 7.2.4` 可以运行，但 WSL2 内核不提供 `cycles`、`instructions`、
`cache-references`、`cache-misses`、`branches` 和 `branch-misses` 等 hardware PMU
事件；`kernel.perf_event_paranoid=2`。因此本轮不能计算 IPC 或 cache miss ratio，
这是环境能力限制，不是零次事件。

可用的软件事件对 1024³、50 次 kernel 的 process-level workload 给出：

| Threads | task-clock (ms) | Page faults |
|---:|---:|---:|
| 1 | 2112.84 | 4238 |
| 2 | 2643.36 | 4244 |
| 4 | 3356.52 | 4249 |
| 8 | 6240.46 | 4658 |
| 10 | 7978.22 | 4862 |
| 20 | 13165.47 | 5884 |

`task-clock` 是各线程 CPU 时间的累计量，不是 wall-clock。它随线程数增加，说明更短的
响应时间伴随更多总 CPU 时间和线程管理成本。WSL2 在本轮把 context switches 与 CPU
migrations 都报告为零，这与虚拟化计数语义有关，不能据此证明实际没有调度或迁移。

## 数值行为

不同线程数写入互不重叠的 C 行，且每个元素内部的 K 累加顺序没有改变，所以各线程数
得到相同的误差摘要。256³、512³、1024³ 的 max absolute error 分别为
1.212e-05、2.932e-05、7.589e-05，`failure_count=0`。

## 解释边界

结果来自 WSL2 开发环境，不是论文级硬件结论。当前线程计时包含每次创建与 join，未使用
常驻线程池；也未固定 affinity、频率或 NUMA placement。guest 显示 10 core/20 logical
CPU，但不能据此还原宿主处理器的完整异构拓扑。硬件 PMU 数据需要在原生 Linux 重跑。

## 结论与下一步

Phase 1.7 证明了 SIMD 微内核外层可以通过 spatial M-axis partition 获得线程级并行，
同时说明矩阵规模和线程开销决定最佳并行度：“线程更多”并不必然更快。至此 Phase 1
已经建立从 naive 循环、cache/layout、register/SIMD 到 thread-level parallelism 的完整
CPU 优化链。

下一步进入 Phase 2：对代表性 kernel 生成并比较 LLVM IR、优化 pass 结果与最终机器
指令，建立 C++ 源码变换、编译器 lowering 和硬件执行之间的证据链。
