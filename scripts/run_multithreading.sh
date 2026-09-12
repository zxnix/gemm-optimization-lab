#!/usr/bin/env bash
set -euo pipefail

result_root=${1:-results/phase1/multithreading}
sizes=${GEMM_SIZES:-256,512,1024}
repeats=${GEMM_REPEATS:-7}
block_size=${GEMM_BLOCK_SIZE:-128}
thread_counts=${GEMM_THREAD_COUNTS:-1,2,4,8,10,20}
counter_size=${GEMM_COUNTER_SIZE:-1024}
counter_kernel_repeats=${GEMM_COUNTER_KERNEL_REPEATS:-50}
perf_repeats=${GEMM_PERF_REPEATS:-3}

if [[ -n "$(git status --porcelain)" ]]; then
    echo "error: worktree must be clean so results identify one exact source revision" >&2
    exit 1
fi

if ! grep -qwm1 avx2 /proc/cpuinfo || ! grep -qwm1 fma /proc/cpuinfo; then
    echo "error: Phase 1.7 requires an x86 CPU with AVX2 and FMA" >&2
    exit 1
fi

mkdir -p "$result_root"
./scripts/collect_system_info.sh "$result_root/system-info.txt" build/release
{
    echo "requested_thread_counts=$thread_counts"
    echo "online_cpus=$(nproc)"
    echo
    echo "cpu_topology:"
    lscpu -e=CPU,CORE,SOCKET,NODE,ONLINE
} >> "$result_root/system-info.txt"

cmake --preset release
cmake --build --preset release --parallel
ctest --preset release

IFS=',' read -r -a thread_array <<< "$thread_counts"
for thread_count in "${thread_array[@]}"; do
    thread_dir="$result_root/threads-$thread_count"
    mkdir -p "$thread_dir"
    ./build/release/gemm_benchmark \
        --kernel avx2-mt \
        --threads "$thread_count" \
        --block-size "$block_size" \
        --sizes "$sizes" \
        --repeats "$repeats" \
        --csv "$thread_dir/raw-results.csv" \
        2>&1 | tee "$thread_dir/console.txt"
done

counter_root="$result_root/hardware-counters"
mkdir -p "$counter_root"
if ! command -v perf >/dev/null 2>&1; then
    echo "unavailable: perf command is not installed" | tee "$counter_root/status.txt"
    echo "Timing results: $result_root"
    exit 0
fi

software_events=task-clock,context-switches,cpu-migrations,page-faults
hardware_events=cycles,instructions,cache-references,cache-misses,branches,branch-misses
if perf stat -e cycles true >/dev/null 2>&1; then
    events="$software_events,$hardware_events"
    {
        echo "perf=available"
        echo "hardware_events=available"
        echo "software_events=available"
        echo "events=$events"
    } > "$counter_root/status.txt"
elif perf stat -e task-clock true >/dev/null 2>&1; then
    events="$software_events"
    {
        echo "perf=available"
        echo "hardware_events=unavailable"
        echo "software_events=available"
        echo "events=$events"
        echo "kernel.perf_event_paranoid=$(cat /proc/sys/kernel/perf_event_paranoid 2>/dev/null || echo unavailable)"
        echo "reason=hardware PMU events were denied or are unsupported by this kernel"
    } > "$counter_root/status.txt"
else
    {
        echo "perf=available"
        echo "hardware_events=unavailable"
        echo "software_events=unavailable"
        echo "kernel.perf_event_paranoid=$(cat /proc/sys/kernel/perf_event_paranoid 2>/dev/null || echo unavailable)"
        echo "reason=perf_event access was denied or events are unsupported"
    } | tee "$counter_root/status.txt"
    echo "Timing results: $result_root"
    exit 0
fi

for thread_count in "${thread_array[@]}"; do
    thread_dir="$counter_root/threads-$thread_count"
    mkdir -p "$thread_dir"
    # 正确性已由上面的正式 benchmark 与 ctest 验证。这里增加 kernel repeats，
    # 使进程启动、初始化和一次 warm-up 在 perf 进程级统计中的占比尽量降低。
    perf stat \
        --field-separator , \
        --repeat "$perf_repeats" \
        --event "$events" \
        --output "$thread_dir/perf-stat.csv" \
        ./build/release/gemm_benchmark \
            --kernel avx2-mt \
            --threads "$thread_count" \
            --block-size "$block_size" \
            --sizes "$counter_size" \
            --repeats "$counter_kernel_repeats" \
            --skip-verification \
        > "$thread_dir/workload.txt"
done

echo "Results: $result_root"
