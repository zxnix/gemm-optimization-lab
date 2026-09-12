#!/usr/bin/env bash
set -euo pipefail

output_path=${1:-/dev/stdout}
git_commit=$(git rev-parse HEAD)
git_dirty=$([ -n "$(git status --porcelain)" ] && echo true || echo false)
mkdir -p "$(dirname "$output_path")"

{
    echo "timestamp_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "git_commit=$git_commit"
    echo "git_dirty=$git_dirty"
    echo "distribution=$(sed -n 's/^PRETTY_NAME=//p' /etc/os-release | tr -d '"')"
    echo "kernel=$(uname -srmo)"
    echo "wsl=$([ -n "${WSL_DISTRO_NAME:-}" ] && echo true || echo false)"
    echo "architecture=$(uname -m)"
    lscpu | sed -n -e 's/^Model name:[[:space:]]*/cpu_model=/p' \
                     -e 's/^CPU(s):[[:space:]]*/logical_cpus=/p' \
                     -e 's/^L1d cache:[[:space:]]*/l1d_cache=/p' \
                     -e 's/^L2 cache:[[:space:]]*/l2_cache=/p' \
                     -e 's/^L3 cache:[[:space:]]*/l3_cache=/p'
    echo "compiler=$(c++ --version | head -n 1)"
    echo "cmake=$(cmake --version | head -n 1)"
    echo "ninja=$(ninja --version)"
    echo "build_type=Release"
    if [[ -f build/compile_commands.json ]]; then
        echo "compile_commands=build/compile_commands.json"
    fi
    cmake -L -N build 2>/dev/null | sed -n 's/^CMAKE_CXX_FLAGS_RELEASE:STRING=/release_flags=/p'
} > "$output_path"
