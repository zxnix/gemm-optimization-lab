#!/usr/bin/env bash
set -euo pipefail

result_root=${1:-results/phase1/packing}
sizes=${GEMM_SIZES:-256,512,1024}
repeats=${GEMM_REPEATS:-7}
block_sizes=${GEMM_BLOCK_SIZES:-16,32,64,128}

if [[ -n "$(git status --porcelain)" ]]; then
    echo "error: worktree must be clean so results identify one exact source revision" >&2
    exit 1
fi

mkdir -p "$result_root"
./scripts/collect_system_info.sh "$result_root/system-info.txt" build/release

cmake --preset release
cmake --build --preset release --parallel
ctest --preset release

mkdir -p "$result_root/ikj"
./build/release/gemm_benchmark \
    --kernel ikj \
    --sizes "$sizes" \
    --repeats "$repeats" \
    --csv "$result_root/ikj/raw-results.csv" \
    2>&1 | tee "$result_root/ikj/console.txt"

IFS=',' read -r -a sizes_array <<< "$block_sizes"
for block_size in "${sizes_array[@]}"; do
    for kernel in blocked packed; do
        kernel_dir="$result_root/$kernel-b$block_size"
        mkdir -p "$kernel_dir"
        ./build/release/gemm_benchmark \
            --kernel "$kernel" \
            --block-size "$block_size" \
            --sizes "$sizes" \
            --repeats "$repeats" \
            --csv "$kernel_dir/raw-results.csv" \
            2>&1 | tee "$kernel_dir/console.txt"
    done
done

echo "Results: $result_root"
