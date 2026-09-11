# FP32 GEMM 数值验证

A、B、C 和被测累加器均为 FP32。每次乘加可能舍入，因此不要求结果与高精度 reference 逐 bit 相同。

```cpp
reference += static_cast<double>(a(i, k)) * static_cast<double>(b(k, j));
```

转换必须发生在乘法前。两个有限 FP32 的精确乘积可由 FP64 表示，但大量乘积的 FP64 累加仍可能舍入，所以它是高精度 reference，不是无限精度真值。

默认通过条件为 `abs(error) <= 1e-4 + 1e-4*abs(reference)`。绝对容限处理接近零的结果，相对容限处理较大结果。改变 reduction 顺序、使用 FMA 或 `fast-math` 后必须重新分析误差。
