#!/usr/bin/env bash
set -euo pipefail

if (($# != 2)); then
    echo "usage: $0 SOURCE_DIR BUILD_DIR" >&2
    exit 2
fi

source_dir=$1
build_dir=$2

case $(uname -m) in
    x86_64|amd64|i?86) ;;
    *)
        echo "SKIP: ISA boundary audit currently targets x86."
        exit 77
        ;;
esac

for tool in objdump nm; do
    if ! command -v "$tool" >/dev/null; then
        echo "error: required tool not found: $tool" >&2
        exit 1
    fi
done

find_object() {
    local source_name=$1
    local object
    object=$(find "$build_dir/CMakeFiles" -path "*/gemm_core.dir/src/kernels/$source_name.o" -print -quit)
    if [[ -z "$object" ]]; then
        echo "error: object not found for $source_name" >&2
        exit 1
    fi
    printf '%s\n' "$object"
}

portable_object=$(find_object gemm_microkernel.cpp)
avx2_object=$(find_object gemm_avx2.cpp)
parallel_object=$(find_object gemm_avx2_parallel.cpp)

audit_dir=$(mktemp -d "$build_dir/isa-audit.XXXXXX")
trap 'rm -rf "$audit_dir"' EXIT

objdump -d -M intel "$portable_object" > "$audit_dir/portable.asm"
objdump -d -M intel "$avx2_object" > "$audit_dir/avx2.asm"
objdump -d -M intel "$parallel_object" > "$audit_dir/parallel.asm"

avx_pattern='(ymm[0-9]+|zmm[0-9]+|vfmadd[[:alnum:]]*|vmov[[:alnum:]]*|vbroadcast[[:alnum:]]*)'

if grep -Eiq "$avx_pattern" "$audit_dir/portable.asm"; then
    echo "error: portable object contains AVX-family instructions" >&2
    exit 1
fi
if grep -Eiq "$avx_pattern" "$audit_dir/parallel.asm"; then
    echo "error: parallel scheduler object contains AVX-family instructions" >&2
    exit 1
fi
if ! grep -Eiq 'ymm[0-9]+' "$audit_dir/avx2.asm"; then
    echo "error: AVX2 object does not contain a YMM register" >&2
    exit 1
fi
if ! grep -Eiq 'vfmadd[[:alnum:]]*' "$audit_dir/avx2.asm"; then
    echo "error: AVX2 object does not contain an FMA instruction" >&2
    exit 1
fi

if grep -Eq -- '-march(=| )|-mavx2|-mfma' "$build_dir/compile_commands.json"; then
    echo "error: global target-specific compiler flag detected" >&2
    exit 1
fi

mapfile -t intrinsic_sources < <(
    grep -RIl --include='*.cpp' --include='*.hpp' 'immintrin\.h' "$source_dir/src"
)
if (("${#intrinsic_sources[@]}" != 1)); then
    echo "error: expected exactly one immintrin.h source" >&2
    exit 1
fi
expected_intrinsic_source="$source_dir/src/kernels/gemm_avx2.cpp"
if [[ "${intrinsic_sources[0]}" != "$expected_intrinsic_source" ]]; then
    echo "error: immintrin.h escaped the dedicated AVX2 source" >&2
    exit 1
fi

nm -C --defined-only "$portable_object" > "$audit_dir/portable.nm"
nm -C --defined-only "$avx2_object" > "$audit_dir/avx2.nm"
nm -C --defined-only "$parallel_object" > "$audit_dir/parallel.nm"

grep -Fq 'gemm::gemm_microkernel_4x8' "$audit_dir/portable.nm"
grep -Fq 'gemm::gemm_avx2_4x8' "$audit_dir/avx2.nm"
grep -Fq 'gemm::detail::gemm_avx2_row_range' "$audit_dir/avx2.nm"
grep -Fq 'gemm::gemm_avx2_4x8_parallel' "$audit_dir/parallel.nm"

echo "ISA boundary checks passed."
