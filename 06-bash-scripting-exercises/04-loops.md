# 04 — Loops

Loops are where scripts start saving real time: the same operation over 400 files, arguments, or lines.

---

## `for` over a list

```bash
for fruit in apple banana cherry; do
  echo "I like $fruit"
done
```

`for` over a **file glob** (the most common real use):
```bash
for f in *.log; do
  echo "$f has $(wc -l < "$f") lines"
done
```

Two rules that prevent most bugs:
1. **Quote inside the loop:** `"$f"`.
2. **Guard against "no matches":** if there are no `.log` files, the glob stays literal and you process a
   file called `*.log`. Use:
   ```bash
   shopt -s nullglob
   for f in *.log; do ...
   ```
   or test first: `[[ -e "$f" ]] || continue`.

### Brace expansion (no loop needed)
```bash
echo {1..5}              # 1 2 3 4 5
mkdir -p logs/{2025,2026}/{01..12}   # 24 folders, one command
touch file{01..10}.txt
```
Brace expansion happens **before** the loop runs — it is just text substitution.

---

## C-style `for`

```bash
for ((i = 1; i <= 5; i++)); do
  echo "Step $i"
done
```
Use this when you need an index or a counter, not when iterating files.

---

## `while`

```bash
count=0
while (( count < 5 )); do
  echo "count=$count"
  count=$((count + 1))
done
```

`while read` — the correct way to process a file line by line:
```bash
while IFS= read -r line; do
  echo "LINE: $line"
done < "$file"
```

Piped into `while` (beware of subshells):
```bash
grep ERROR "$log" | while IFS= read -r line; do
  (( errors++ ))          # ⚠️ this variable is lost after the loop!
done
echo "$errors"            # empty/0
```
A pipeline runs each side in a **subshell**. Variables set inside are discarded. Fixes:
```bash
# 1. process substitution keeps the loop in the current shell
while IFS= read -r line; do ((errors++)); done < <(grep ERROR "$log")

# 2. count differently
errors=$(grep -c ERROR "$log")
```

---

## `until`

Runs **while the condition is false** — the opposite of `while`. Rarely needed, occasionally perfect:
```bash
until ping -c1 -W1 host &>/dev/null; do
  echo "waiting for host..."
  sleep 2
done
```

---

## Looping over command output (careful)

```bash
# ✅ best: read lines
while IFS= read -r line; do
  echo "$line"
done < <(find . -name "*.log")

# ⚠️ works but breaks on spaces and globs
for line in $(find . -name "*.log"); do echo "$line"; done

# ✅ safe for paths with spaces/newlines
find . -name "*.log" -print0 | while IFS= read -r -d '' f; do
  echo "$f"
done
```
The pattern `while read -r` + process substitution is the standard professional idiom.

---

## `break` and `continue`

```bash
for f in *.txt; do
  [[ -s "$f" ]] || continue        # skip empty files
  grep -q "SECRET" "$f" && break   # stop at the first match
  echo "checked $f"
done
```

- `continue` — skip to the next iteration.
- `break` — exit the loop entirely.

`break 2` exits two levels of nested loops.

---

## Nested loops (use sparingly)

```bash
for env in dev staging prod; do
  for region in us eu; do
    echo "deploying $env to $region"
  done
done
```
If you have three levels, you probably want a function or a different data structure.

---

## `select`: a menu for free

```bash
PS3="Choose an option: "
select opt in "Show date" "Show disk" "Quit"; do
  case "$opt" in
    "Show date") date ;;
    "Show disk") df -h ;;
    "Quit") break ;;
    *) echo "invalid" ;;
  esac
done
```
Bash prints a numbered menu, reads a number, and sets `$opt`. Great for interactive scripts.

---

## Realistic example: rename files in bulk

```bash
#!/usr/bin/env bash
set -euo pipefail

shopt -s nullglob
for f in *.jpeg; do
  new="${f%.jpeg}.jpg"
  if [[ -e "$new" ]]; then
    echo "skip: $new already exists" >&2
    continue
  fi
  mv -v -- "$f" "$new"
done
```

Note `--` before filenames: it stops a file named `-rf` from being read as an option. A small habit that
prevents a very bad day.

---

## Practice

Write `04-count-lines.sh`:
1. Loop over all `.log` files in a directory (default: current dir, or `$1`).
2. Print `<filename>: <line count>` for each.
3. Skip empty files, but count how many you skipped.
4. Print a total at the end.
5. If no `.log` files exist, print a message and exit `0` (not an error).

Write `04-batch-rename.sh`:
6. Take a prefix as `$1`.
7. Rename every `.txt` file to `<prefix>-<original>`.
8. Refuse to overwrite an existing file.
9. Print a summary: "renamed 4, skipped 1".

Write `04-multiplication.sh`:
10. Print the multiplication table 1–10 × 1–10, neatly aligned (use `printf "%4d"`).

<details>
<summary>Answer: 04-count-lines.sh</summary>

```bash
#!/usr/bin/env bash
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
```
</details>

<details>
<summary>Answer: 04-batch-rename.sh</summary>

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <prefix>" >&2
  exit 1
fi
prefix="$1"

renamed=0
skipped=0

for f in *.txt; do
  new="${prefix}-${f}"
  if [[ -e "$new" ]]; then
    echo "skip (exists): $new" >&2
    skipped=$((skipped + 1))
    continue
  fi
  mv -v -- "$f" "$new"
  renamed=$((renamed + 1))
done

echo "renamed=$renamed skipped=$skipped"
```
</details>

<details>
<summary>Answer: 04-multiplication.sh</summary>

```bash
#!/usr/bin/env bash
set -euo pipefail
for ((i = 1; i <= 10; i++)); do
  for ((j = 1; j <= 10; j++)); do
    printf "%4d" $((i * j))
  done
  printf "\n"
done
```
</details>

## Cheat card

```bash
for x in a b c; do ...; done
for f in *.txt; do ...; done
for ((i=0; i<10; i++)); do ...; done
while read -r line; do ...; done < file
while (( n > 0 )); do ...; done
until cmd; do sleep 1; done
break / continue
shopt -s nullglob      # empty glob -> nothing, not a literal *.txt
```

Next: `05-functions-and-arrays.md`.
