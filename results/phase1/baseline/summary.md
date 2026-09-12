# Phase 1.1 baseline summary

被测提交：`75b9d9ddbc256d244524a5313f9626e7575ee3f7`。系统元数据见 `system-info.txt`，21 条逐次测量见 `raw-results.csv`，原始终端输出见 `console-output.txt`。

| N | Mean time | Median time | Median GFLOP/s | 验证 |
|---:|---:|---:|---:|---|
| 256 | 14.652 ms | 14.389 ms | 2.332 | PASS |
| 512 | 134.666 ms | 132.557 ms | 2.025 | PASS |
| 1024 | 3587.841 ms | 3469.235 ms | 0.619 | PASS |

三个规模均通过联合误差容限。性能随尺寸增长而下降，与 row-major `i-j-k` 对 B 的大 stride 访问假设一致；但 WSL2 中的 wall-clock 数据只能说明相关性，不能单独证明 Cache/TLB miss 是原因。

本次数据较 2026-09-11 的探索性测量更慢且波动更大。项目保留本次完整原始数据，不选择性采用更快结果。后续应通过重复实验、硬件计数器和原生 Linux 测量分析波动来源。
