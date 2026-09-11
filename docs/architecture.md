# 项目结构与职责

当前对象是单线程 FP32 稠密矩阵乘法：`A(M×K) · B(K×N) = C(M×N)`。

```text
Matrix（数据表示）
  ├── gemm_naive（被测 kernel）
  └── verify_gemm（FP64 reference）
            ↑
benchmark 与 tests
```

- `matrix.hpp`：形状、连续内存和 row-major 索引。
- `gemm_naive.cpp`：永久保留的 `i-j-k` 对照实现。
- `verification.cpp`：FP64 reference 与误差报告。
- `main.cpp`：warm-up、计时、统计和 GFLOP/s。
- `test_gemm.cpp`：手工结果、随机非方阵和非法维度测试。

二维元素 `(row,col)` 映射为 `row*cols+col`。行内连续，跨行 stride 为 `cols*sizeof(float)`。核心库不依赖 benchmark 或 tests，后续可替换 kernel 而不改变测量工具。
