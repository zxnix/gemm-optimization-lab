#!/usr/bin/env bash
set -euo pipefail

result_dir=${1:-results/phase1/baseline}
cmake --preset release
cmake --build --preset release --parallel
ctest --preset release
./scripts/collect_system_info.sh "$result_dir/system-info.txt" build/release
./build/release/gemm_benchmark --sizes 256,512,1024 --repeats 7 --csv "$result_dir/raw-results.csv" | tee "$result_dir/console-output.txt"
