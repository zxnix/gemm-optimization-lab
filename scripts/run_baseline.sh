#!/usr/bin/env bash
set -euo pipefail

result_dir=${1:-results/phase1/baseline}
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
ctest --test-dir build --output-on-failure
./scripts/collect_system_info.sh "$result_dir/system-info.txt"
./build/gemm_benchmark --sizes 256,512,1024 --repeats 7 --csv "$result_dir/raw-results.csv" | tee "$result_dir/console-output.txt"
