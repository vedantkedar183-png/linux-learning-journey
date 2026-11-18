#!/usr/bin/env bash
# SOLUTION 03 — file-check.sh

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <path>" >&2
  exit 1
fi

path="$1"

if [[ ! -e "$path" ]]; then
  echo "Not found: $path" >&2
  exit 2
fi

if [[ -L "$path" ]]; then
  echo "$path is a symlink -> $(readlink "$path")"
fi

if [[ -d "$path" ]]; then
  n=$(find "$path" -mindepth 1 -maxdepth 1 | wc -l)
  echo "$path is a directory with $n entries"
elif [[ -f "$path" ]]; then
  size=$(stat -c %s "$path")
  echo "$path is a regular file, $size bytes"
  [[ -r "$path" ]] && echo "  readable"
  [[ -w "$path" ]] && echo "  writable"
  [[ -x "$path" ]] && echo "  executable"
else
  echo "$path is a special file (device, socket, or fifo)"
fi
