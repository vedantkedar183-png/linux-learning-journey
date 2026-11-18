# 05 — Functions, Arrays, and Real Structure

Once a script passes ~30 lines, it needs structure. Functions remove duplication and arrays hold lists. This
is the chapter that makes your scripts look professional.

---

## Functions

```bash
greet() {
  echo "Hello, $1"
}

greet "Alice"      # Hello, Alice
```

Syntax notes:
- `name() { ... }` — the `()` are for looks; Bash does not use them for arguments.
- Arguments are `$1`, `$2`, … **local to the call**.
- Call it like a command: `greet Alice`, not `greet(Alice)`.

### `local` — the most important habit

```bash
counter=0

bad() {
  counter=99          # overwrites the global!
}

good() {
  local counter=99    # separate variable, goes away when the function ends
}

bad;  echo "$counter"   # 99  (oops)
good; echo "$counter"   # 0   (safe)
```

**Every variable inside a function should be `local`.** No exceptions. This prevents the worst class of
Bash bugs: a function silently changing a caller's state.

### Returning values

Bash functions return an **exit status** (0–255), not a value. To return data, print it and capture it:

```bash
get_date() {
  date +%F
}
today=$(get_date)
echo "$today"
```

```bash
is_root() {
  [[ $(id -u) -eq 0 ]]
}
if is_root; then echo "you are root"; fi
```

`return N` sets the exit status:
```bash
check_file() {
  [[ -f "$1" ]] || { echo "missing: $1" >&2; return 1; }
  return 0
}
```
⚠️ `return 256` wraps to `0` (only 8 bits). Use 0–255.

### A useful `die` function

```bash
die() {
  echo "ERROR: $*" >&2
  exit 1
}

[[ -f "$config" ]] || die "config not found: $config"
```
Two lines of code that make every script cleaner.

### `usage`

```bash
usage() {
  cat <<EOF
Usage: $(basename "$0") [options] <file>

Options:
  -o DIR    output directory (default: ./out)
  -v        verbose
  -h        show this help
EOF
}
```
`<<EOF` is a **here-document**: multi-line text, with variables expanded (use `<<'EOF'` to keep them
literal). Perfect for help text.

---

## Arrays

```bash
files=("a.txt" "b.log" "c with space.txt")

echo "${files[0]}"        # first element (index starts at 0)
echo "${files[-1]}"       # last element (Bash 4.3+)
echo "${#files[@]}"       # number of elements -> 3
echo "${files[@]}"        # all elements
```

**Always quote `"${arr[@]}"`** — it keeps each element as one word, spaces included.

Loop:
```bash
for f in "${files[@]}"; do
  echo "processing: $f"
done
```

Append:
```bash
files+=("d.conf")
```

Slice:
```bash
echo "${files[@]:1:2}"    # 2 elements starting at index 1
```

Delete an element (leaves a gap):
```bash
unset 'files[1]'
```

### Building an array from a command
```bash
mapfile -t lines < <(grep ERROR "$log")     # one element per line, no splitting
printf '%s\n' "${lines[@]}"

# older/portable way
IFS=$'\n' read -r -d '' -a lines < <(grep ERROR "$log") || true
```

⚠️ `arr=($(ls))` breaks on spaces and globs. Use `mapfile` or a glob:
```bash
arr=(*.log)     # safe: one element per matching filename
```

---

## Associative arrays (dictionaries)

Bash 4+:
```bash
declare -A counts
counts["dev"]=3
counts["ops"]=1
counts["dev"]=$(( ${counts["dev"]} + 1 ))    # -> 4

for key in "${!counts[@]}"; do
  echo "$key = ${counts[$key]}"
done
```

A very common use: counting occurrences.
```bash
declare -A ext_count
for f in *; do
  [[ -f "$f" ]] || continue
  ext="${f##*.}"
  [[ "$ext" == "$f" ]] && ext="(none)"
  ext_count["$ext"]=$(( ${ext_count["$ext"]:-0} + 1 ))
done

for e in "${!ext_count[@]}"; do
  printf '%-10s %d\n' "$e" "${ext_count[$e]}"
done | sort -k2 -rn
```
`${ext_count["$ext"]:-0}` handles the first time a key is seen. This idiom appears everywhere.

---

## Structuring a real script

```bash
#!/usr/bin/env bash
set -euo pipefail

# ---------- constants ----------
readonly SCRIPT_NAME=$(basename "$0")
readonly LOG_DIR="${LOG_DIR:-$HOME/logs}"

# ---------- helpers ----------
die()   { echo "ERROR: $*" >&2; exit 1; }
log()   { printf '[%s] %s\n' "$(date +%T)" "$*"; }
usage() { echo "Usage: $SCRIPT_NAME [-n COUNT] <target>"; }

# ---------- steps ----------
parse_args() {
  count=1
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n) count="${2:?missing value for -n}"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      -*) die "unknown option: $1" ;;
      *)  target="$1"; shift ;;
    esac
  done
  [[ -n "${target:-}" ]] || { usage; exit 1; }
}

do_work() {
  local i
  for ((i = 1; i <= count; i++)); do
    log "run $i on $target"
  done
}

# ---------- entry ----------
main() {
  parse_args "$@"
  do_work
}

main "$@"
```

Why this shape:
- **constants at top** — easy to change, easy to read
- **small helpers** — reused everywhere
- **`parse_args`** — all input validation in one place
- **`main "$@"`** — the whole script has one entry point, so you can `source` it in tests
- **`readonly`** — accidental reassignment fails loudly

This template fits 90% of scripts. Use it.

---

## Practice

Write `05-functions.sh` containing:

1. `die()` — prints to stderr and exits 1.
2. `log()` — prints `[HH:MM:SS] message`.
3. `usage()` — here-document help text with `basename "$0"`.
4. `is_number()` — returns success if `$1` is all digits.
5. `count_files(dir)` — prints the number of regular files (uses a `local` variable).
6. `main()` — validates one argument is a directory, then logs the file count.
7. `main "$@"` at the bottom.

Write `05-array-summary.sh`:

8. Read all `.log` files into an array safely.
9. Print the count of files.
10. Loop and print each file with its size.
11. Build an associative array of counts per extension in the current directory.
12. Print the extensions sorted by count, highest first.

<details>
<summary>Answer: 05-functions.sh</summary>

```bash
#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_NAME=$(basename "$0")

die() { echo "ERROR: $*" >&2; exit 1; }
log() { printf '[%s] %s\n' "$(date +%T)" "$*"; }

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME <directory>

Counts regular files in the given directory.
EOF
}

is_number() { [[ "$1" =~ ^[0-9]+$ ]]; }

count_files() {
  local dir="$1" n
  [[ -d "$dir" ]] || return 1
  n=$(find "$dir" -maxdepth 1 -type f | wc -l)
  echo "$n"
}

main() {
  [[ $# -eq 1 ]] || { usage; exit 1; }
  local dir="$1"
  [[ -d "$dir" ]] || die "not a directory: $dir"
  local n
  n=$(count_files "$dir") || die "count failed"
  log "files in $dir: $n"
}

main "$@"
```
</details>

<details>
<summary>Answer: 05-array-summary.sh</summary>

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

logs=( *.log )
echo "log files: ${#logs[@]}"

for f in "${logs[@]}"; do
  printf '%-30s %s\n' "$f" "$(du -h "$f" | cut -f1)"
done

declare -A ext
for f in *; do
  [[ -f "$f" ]] || continue
  e="${f##*.}"
  [[ "$e" == "$f" ]] && e="(none)"
  ext["$e"]=$(( ${ext["$e"]:-0} + 1 ))
done

echo "--- extensions ---"
for e in "${!ext[@]}"; do
  printf '%s %d\n' "$e" "${ext[$e]}"
done | sort -k2 -rn
```
</details>

## Cheat card

```bash
f() { local x="$1"; echo "$x"; }
result=$(f hello)
return 0 / return 1
die() { echo "ERROR: $*" >&2; exit 1; }
arr=("a b" "c")
"${arr[0]}"  "${#arr[@]}"  "${arr[@]}"
arr+=("new")
mapfile -t lines < <(cmd)
declare -A map; map["k"]=v; "${!map[@]}"
readonly CONST=value
main "$@"
```

Next: `06-text-processing.md`.
