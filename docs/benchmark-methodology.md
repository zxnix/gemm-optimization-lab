# Benchmark 方法

```text
分配与初始化       不计时
warm-up 1 次       不计时
正式 GEMM 7 次     仅 kernel 计时
统计、输出、验证   不计时
```

计时使用 `std::chrono::steady_clock`。GEMM 约定 `FLOPs=2MNK`，`GFLOP/s=2MNK/(time_seconds×1e9)`。mean 使用全部样本但受异常值影响；median 更接近典型运行，两者都应报告。

比较 kernel 时保持尺寸、输入、编译器、参数、线程、warm-up 和重复次数一致。WSL2 与 Windows 共享资源，因此数据适合开发与趋势分析，不直接作为论文级裸机结论。

使用 `--sizes` 测量多组方阵，或同时提供 `--m/--n/--k` 测量一个一般形状；两种模式不能混用。`--csv` 将逐次原始数据及编译元数据写入 CSV。执行 `scripts/run_baseline.sh` 可一次完成 Release 配置、构建、测试、系统信息采集和默认实验。
