#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

failed=0

if git grep -nI -E '[[:blank:]]+$' -- . ':(exclude)artifacts/**' ':(exclude)results/**'; then
    echo "error: trailing whitespace found" >&2
    failed=1
fi

mapfile -d '' cpp_files < <(
    git ls-files -z -- '*.cpp' '*.hpp'
)

if ! awk '
    length($0) > 100 {
        printf "%s:%d: line exceeds 100 columns (%d)\n",
               FILENAME, FNR, length($0)
        failed = 1
    }
    END { exit failed }
' "${cpp_files[@]}"; then
    failed=1
fi

if grep -n $'\t' "${cpp_files[@]}"; then
    echo "error: tab found in C++ source" >&2
    failed=1
fi

mapfile -d '' checked_files < <(
    git ls-files -z -- '*.cpp' '*.hpp' '*.json' '*.md' '*.sh' '*.txt' '*.yml' '*.yaml' '.editorconfig' 'CMakeLists.txt' ':(exclude)artifacts/**' ':(exclude)results/**'
)

for file in "${checked_files[@]}"; do
    last_byte=$(tail -c 1 "$file" | od -An -t x1 | tr -d '[:space:]')
    if [[ "$last_byte" != "0a" ]]; then
        echo "$file: missing final newline" >&2
        failed=1
    fi
done

while IFS= read -r -d '' script; do
    if ! bash -n "$script"; then
        failed=1
    fi
done < <(git ls-files -z -- '*.sh')

if ((failed != 0)); then
    exit 1
fi

echo "Source hygiene checks passed."
