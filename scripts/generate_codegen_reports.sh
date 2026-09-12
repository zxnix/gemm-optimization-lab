#!/usr/bin/env bash
set -euo pipefail

artifact_root=${1:-artifacts/phase1/codegen-o3}
analysis_dir=build/release/codegen-analysis
common_flags=(-std=c++17 -Iinclude -O3 -DNDEBUG)

if [[ -n "$(git status --porcelain)" ]]; then
    echo "error: worktree must be clean so reports identify one exact source revision" >&2
    exit 1
fi

mkdir -p "$artifact_root" "$analysis_dir"
{
    echo "timestamp_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "git_commit=$(git rev-parse HEAD)"
    echo "compiler=$(c++ --version | head -n 1)"
    echo "flags=-std=c++17 -Iinclude -O3 -DNDEBUG"
    echo "target_flags=no -march=native, -mavx2, or -mfma"
} > "$artifact_root/metadata.txt"

for entry in \
    "ikj:src/kernels/gemm_ikj.cpp" \
    "blocked:src/kernels/gemm_blocked.cpp" \
    "packed:src/kernels/gemm_packed.cpp"; do
    kernel=${entry%%:*}
    source=${entry#*:}
    kernel_dir="$artifact_root/$kernel"
    mkdir -p "$kernel_dir"

    c++ "${common_flags[@]}" -S -masm=intel \
        "$source" -o "$kernel_dir/assembly.s"
    c++ "${common_flags[@]}" -c \
        -fopt-info-vec-all="$kernel_dir/vectorization.txt" \
        "$source" -o "$analysis_dir/$kernel.o"
    {
        echo "source=$source"
        echo "assembly_command=c++ -std=c++17 -Iinclude -O3 -DNDEBUG -S -masm=intel $source"
        echo "vectorization_command=c++ -std=c++17 -Iinclude -O3 -DNDEBUG -c -fopt-info-vec-all=$kernel_dir/vectorization.txt $source"
    } > "$kernel_dir/commands.txt"
done

echo "Artifacts: $artifact_root"
