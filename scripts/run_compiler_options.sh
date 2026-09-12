#!/usr/bin/env bash
set -euo pipefail

result_root=${1:-results/phase1/compiler-options}
artifact_root=${2:-artifacts/phase1/compiler-options}
sizes=${GEMM_SIZES:-256,512,1024}
repeats=${GEMM_REPEATS:-7}

if [[ -n "$(git status --porcelain)" ]]; then
    echo "error: worktree must be clean so results identify one exact source revision" >&2
    exit 1
fi

mkdir -p "$result_root" "$artifact_root"
./scripts/collect_system_info.sh "$result_root/system-info.txt"

for level in O0 O1 O2 O3; do
    build_dir="build-phase12/$level"
    result_dir="$result_root/$level"
    artifact_dir="$artifact_root/$level"
    mkdir -p "$result_dir" "$artifact_dir"

    cmake -S . -B "$build_dir" -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_FLAGS_RELEASE="-$level -DNDEBUG" \
        -DGEMM_OPT_LEVEL="$level"
    cmake --build "$build_dir"
    ctest --test-dir "$build_dir" --output-on-failure

    "$build_dir/gemm_benchmark" \
        --sizes "$sizes" \
        --repeats "$repeats" \
        --csv "$result_dir/raw-results.csv" \
        2>&1 | tee "$result_dir/console.txt"

    cp "$build_dir/compile_commands.json" "$artifact_dir/compile_commands.json"
    size "$build_dir/gemm_benchmark" > "$artifact_dir/binary-size.txt"
    c++ -std=c++17 -Iinclude "-$level" -DNDEBUG -S -masm=intel \
        src/gemm_naive.cpp -o "$artifact_dir/gemm_naive.s"
    c++ -std=c++17 -Iinclude "-$level" -DNDEBUG -c \
        -fopt-info-vec-all="$artifact_dir/vectorization.txt" \
        src/gemm_naive.cpp -o "$build_dir/gemm_naive-analysis.o"
done

echo "Results:   $result_root"
echo "Artifacts: $artifact_root"
