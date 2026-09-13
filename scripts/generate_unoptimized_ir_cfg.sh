#!/usr/bin/env bash
set -euo pipefail

input_ir=${1:-artifacts/phase2/llvm-baseline/naive/O0/llvm-ir.ll}
output_dir=${2:-artifacts/phase2/unoptimized-ir/naive}
mangled_name=_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_
expected_blocks=(
    entry
    lor.lhs.false
    lor.lhs.false5
    if.then
    invoke.cont
    lpad
    if.end
    for.cond
    for.body
    for.cond13
    for.body15
    for.cond16
    for.body18
    for.inc
    for.end
    for.inc22
    for.end24
    for.inc25
    for.end27
    eh.resume
)

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

if [[ -n "$(git status --porcelain)" ]]; then
    echo "error: worktree must be clean so metadata identifies one revision" >&2
    exit 1
fi

for tool in opt c++filt sha256sum; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "error: required tool is missing: $tool" >&2
        exit 1
    fi
done

if [[ ! -f "$input_ir" ]]; then
    echo "error: input IR does not exist: $input_ir" >&2
    exit 1
fi

opt -passes=verify -disable-output "$input_ir"

cfg_work_dir=$(mktemp -d /tmp/gemm-phase22-cfg.XXXXXX)
trap 'rm -rf "$cfg_work_dir"' EXIT

(
    cd "$cfg_work_dir"
    opt -passes=dot-cfg-only -disable-output "$repo_root/$input_ir"
)

raw_cfg="$cfg_work_dir/.$mangled_name.dot"
if [[ ! -f "$raw_cfg" ]]; then
    echo "error: opt did not generate the expected gemm_naive CFG" >&2
    exit 1
fi

declare -A block_by_node=()
while IFS=$'\t' read -r node_id block_name; do
    block_by_node["$node_id"]=$block_name
done < <(
    sed -nE \
        's/^[[:space:]]*(Node0x[[:xdigit:]]+).*label="\{([^|}]*)[|}].*/\1\t\2/p' \
        "$raw_cfg"
)

if ((${#block_by_node[@]} != ${#expected_blocks[@]})); then
    echo "error: expected ${#expected_blocks[@]} CFG blocks, found ${#block_by_node[@]}" >&2
    exit 1
fi

for block_name in "${expected_blocks[@]}"; do
    found=0
    for mapped_name in "${block_by_node[@]}"; do
        if [[ "$mapped_name" == "$block_name" ]]; then
            found=1
            break
        fi
    done
    if ((found == 0)); then
        echo "error: expected CFG block is missing: $block_name" >&2
        exit 1
    fi
done

mkdir -p "$output_dir"
cfg_file="$output_dir/cfg.dot"
edge_count=0

{
    echo 'digraph "gemm_naive O0 CFG" {'
    echo '  label="gemm::gemm_naive -O0 control-flow graph";'
    echo '  rankdir=TB;'
    echo '  node [shape=box, fontname="monospace"];'
    echo
    for block_name in "${expected_blocks[@]}"; do
        printf '  "%s";\n' "$block_name"
    done
    echo

    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*(Node0x[[:xdigit:]]+)(:s([01]))?[[:space:]]*-\>[[:space:]]*(Node0x[[:xdigit:]]+) ]]; then
            source_node=${BASH_REMATCH[1]}
            branch_port=${BASH_REMATCH[3]}
            target_node=${BASH_REMATCH[4]}
            source_block=${block_by_node[$source_node]}
            target_block=${block_by_node[$target_node]}
            edge_label=

            if [[ -n "$branch_port" ]]; then
                if [[ "$branch_port" == 0 ]]; then
                    edge_label=T
                else
                    edge_label=F
                fi
            elif [[ "$source_block" == if.then ]]; then
                if [[ "$target_block" == invoke.cont ]]; then
                    edge_label=normal
                elif [[ "$target_block" == lpad ]]; then
                    edge_label=unwind
                fi
            fi

            if [[ -n "$edge_label" ]]; then
                printf '  "%s" -> "%s" [label="%s"];\n' \
                    "$source_block" "$target_block" "$edge_label"
            else
                printf '  "%s" -> "%s";\n' "$source_block" "$target_block"
            fi
            ((edge_count += 1))
        fi
    done < "$raw_cfg"
    echo '}'
} > "$cfg_file"

if ((edge_count != 24)); then
    echo "error: expected 24 CFG edges, found $edge_count" >&2
    exit 1
fi

{
    echo "git_commit=$(git rev-parse HEAD)"
    echo "input_ir=$input_ir"
    echo "input_ir_sha256=$(sha256sum "$input_ir" | awk '{ print $1 }')"
    echo "function_mangled=$mangled_name"
    echo "function_demangled=$(c++filt "$mangled_name")"
    echo "generator=$(opt --version | awk '/LLVM version/ { print $0; exit }' | sed 's/^[[:space:]]*//')"
    echo "generator_pass=dot-cfg-only"
    echo "normalization=replace process-local node addresses with LLVM basic-block names"
    echo "basic_blocks=${#block_by_node[@]}"
    echo "edges=$edge_count"
} > "$output_dir/metadata.txt"
echo "Unoptimized IR CFG artifacts: $output_dir"
