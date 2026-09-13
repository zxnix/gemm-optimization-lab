#!/usr/bin/env bash
set -euo pipefail

artifact_root=${1:-artifacts/phase2/llvm-baseline}
analysis_dir=build/phase2-llvm-baseline
source_file=src/kernels/gemm_naive.cpp
required_tools=(clang++ opt llc llvm-dis llvm-diff llvm-objdump llvm-mca)

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

if [[ -n "$(git status --porcelain)" ]]; then
    echo "error: worktree must be clean so reports identify one exact source revision" >&2
    exit 1
fi

for tool in "${required_tools[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "error: required LLVM tool is missing: $tool" >&2
        exit 1
    fi
done

clang_major=$(clang++ -dumpversion | cut -d. -f1)
llvm_major=$(opt --version | awk '/LLVM version/ { split($3, version, "."); print version[1]; exit }')
if [[ "$clang_major" != "$llvm_major" ]]; then
    echo "error: clang++ major version $clang_major does not match LLVM $llvm_major" >&2
    exit 1
fi

mkdir -p "$artifact_root/toolchain" "$analysis_dir"

{
    echo "timestamp_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "git_commit=$(git rev-parse HEAD)"
    echo "os=$(sed -n 's/^PRETTY_NAME="\(.*\)"/\1/p' /etc/os-release)"
    echo "kernel=$(uname -sr)"
    echo "architecture=$(uname -m)"
    echo "target_triple=$(clang++ -print-target-triple)"
    echo "clang=$(clang++ --version | head -n 1)"
    echo "llvm=$(opt --version | awk '/LLVM version/ { print; exit }' | sed 's/^[[:space:]]*//')"
    echo "source=$source_file"
    echo "common_flags=-std=c++17 -Iinclude -DNDEBUG -fno-discard-value-names -g0"
    echo "target_policy=no -march=native, -mavx2, -mfma, or -ffast-math"
} > "$artifact_root/toolchain/metadata.txt"

for level in O0 O3; do
    level_dir="$artifact_root/naive/$level"
    object_file="$analysis_dir/gemm_naive_$level.o"
    mkdir -p "$level_dir"

    clang++ -std=c++17 -Iinclude -DNDEBUG -fno-discard-value-names -g0 \
        "-$level" -S -emit-llvm "$source_file" -o "$level_dir/llvm-ir.ll"
    opt -passes=verify -disable-output "$level_dir/llvm-ir.ll"
    llc "-$level" --x86-asm-syntax=intel \
        "$level_dir/llvm-ir.ll" -o "$level_dir/assembly.s"
    clang++ -std=c++17 -Iinclude -DNDEBUG -g0 "-$level" \
        -c "$source_file" -o "$object_file"
    llvm-objdump --demangle --disassemble --x86-asm-syntax=intel \
        "$object_file" > "$level_dir/object-disassembly.txt"

    {
        echo "source=$source_file"
        echo "ir_command=clang++ -std=c++17 -Iinclude -DNDEBUG -fno-discard-value-names -g0 -$level -S -emit-llvm $source_file"
        echo "verify_command=opt -passes=verify -disable-output $level_dir/llvm-ir.ll"
        echo "assembly_command=llc -$level --x86-asm-syntax=intel $level_dir/llvm-ir.ll"
        echo "object_command=clang++ -std=c++17 -Iinclude -DNDEBUG -g0 -$level -c $source_file"
        echo "disassembly_command=llvm-objdump --demangle --disassemble --x86-asm-syntax=intel $object_file"
    } > "$level_dir/commands.txt"

    {
        echo "ir_lines=$(wc -l < "$level_dir/llvm-ir.ll")"
        echo "alloca=$(grep -Ec '(^|[[:space:]])alloca([[:space:]]|$)' "$level_dir/llvm-ir.ll" || true)"
        echo "load=$(grep -Ec '(^|[[:space:]])load([[:space:]]|$)' "$level_dir/llvm-ir.ll" || true)"
        echo "store=$(grep -Ec '(^|[[:space:]])store([[:space:]]|$)' "$level_dir/llvm-ir.ll" || true)"
        echo "phi=$(grep -Ec '(^|[[:space:]])phi([[:space:]]|$)' "$level_dir/llvm-ir.ll" || true)"
        echo "getelementptr=$(grep -Ec '(^|[[:space:]])getelementptr([[:space:]]|$)' "$level_dir/llvm-ir.ll" || true)"
        echo "fmul=$(grep -Ec '(^|[[:space:]])fmul([[:space:]]|$)' "$level_dir/llvm-ir.ll" || true)"
        echo "fadd=$(grep -Ec '(^|[[:space:]])fadd([[:space:]]|$)' "$level_dir/llvm-ir.ll" || true)"
        echo "fmuladd=$(grep -Ec 'call float @llvm\.fmuladd\.f32' "$level_dir/llvm-ir.ll" || true)"
        echo "vector_float=$(grep -Ec '<[0-9]+ x float>' "$level_dir/llvm-ir.ll" || true)"
    } > "$level_dir/ir-stats.txt"
done

echo "LLVM baseline artifacts: $artifact_root"
