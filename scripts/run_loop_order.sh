#!/usr/bin/env bash
set -euo pipefail

result_root=${1:-results/phase1/loop-order}
sizes=${GEMM_SIZES:-256,512,1024}
repeats=${GEMM_REPEATS:-7}

if [[ -n "$(git status --porcelain)" ]]; then
    echo "error: worktree must be clean so results identify one exact source revision" >&2
    exit 1
fi

mkdir -p "$result_root"
./scripts/collect_system_info.sh "$result_root/system-info.txt" build/release

cmake --preset release
cmake --build --preset release --parallel
ctest --preset release

for kernel in naive ikj; do
    kernel_dir="$result_root/$kernel"
    mkdir -p "$kernel_dir"
    ./build/release/gemm_benchmark \
        --kernel "$kernel" \
        --sizes "$sizes" \
        --repeats "$repeats" \
        --csv "$kernel_dir/raw-results.csv" \
        2>&1 | tee "$kernel_dir/console.txt"
done

echo "Results: $result_root"
