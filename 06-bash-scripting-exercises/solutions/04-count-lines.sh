#!/usr/bin/env bash
# SOLUTION 04 — count-lines.sh

set -euo pipefail
shopt -s nullglob

dir="${1:-.}"
if [[ ! -d "$dir" ]]; then
  echo "Not a directory: $dir" >&2
  exit 1
fi

total=0
skipped=0
files=0

for f in "$dir"/*.log; do
  if [[ ! -s "$f" ]]; then
    skipped=$((skipped + 1))
    continue
  fi
  lines=$(wc -l < "$f")
  printf '%-40s %8d\n' "$(basename "$f")" "$lines"
  total=$((total + lines))
  files=$((files + 1))
done

if (( files == 0 )); then
  echo "No non-empty .log files in $dir"
  exit 0
fi

echo "----------------------------------------"
printf 'files=%d skipped=%d total_lines=%d\n' "$files" "$skipped" "$total"
