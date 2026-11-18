# 03 — Conditionals: Making Decisions

A script that always does the same thing is barely a script. Conditionals let it react: "if the file
exists, back it up; otherwise, complain and stop."

---

## The basic `if`

```bash
if [[ -f "$file" ]]; then
  echo "File exists"
fi
```

The shape is fixed:
```bash
if <condition>; then
  <commands>
elif <another condition>; then
  <commands>
else
  <commands>
fi
```

- `then` can be on the same line after `;` or on its own line.
- `fi` ends the block (that is `if` backwards — Bash is full of these).
- **Indent** the body. Bash does not care; humans do.

---

## `[ ]` vs `[[ ]]` — which one?

Use **`[[ ]]`** in Bash scripts. It is safer and has more features.

| Feature | `[ ]` (POSIX) | `[[ ]]` (Bash) |
|---|---|---|
| Unquoted variables with spaces | breaks | safe |
| `&&` / `\|\|` inside | no (use `-a`/`-o`) | yes |
| Pattern matching `== *.txt` | no | yes |
| Regex `=~` | no | yes |
| `<` `>` string comparison | needs escaping | works |

The old `[ ]` is still fine for `/bin/sh` scripts. In `#!/usr/bin/env bash`, prefer `[[ ]]`.

---

## String tests

```bash
if [[ -z "$name" ]]; then echo "empty"; fi        # -z: zero length
if [[ -n "$name" ]]; then echo "not empty"; fi    # -n: non-zero length

if [[ "$a" == "$b" ]]; then echo "equal"; fi      # == (also =)
if [[ "$a" != "$b" ]]; then echo "different"; fi

if [[ "$file" == *.log ]]; then echo "a log file"; fi   # glob match (no quotes on pattern)
if [[ "$line" =~ ^ERROR ]]; then echo "starts with ERROR"; fi  # regex
if [[ "$name" < "m" ]]; then echo "alphabetically before m"; fi
```

---

## Numeric tests (with `-eq`, `-lt`, …)

```bash
if [[ "$age" -ge 18 ]]; then echo "adult"; fi
```

| Operator | Meaning | | Operator | Meaning |
|---|---|---|---|---|
| `-eq` | equal | | `-ne` | not equal |
| `-lt` | less than | | `-le` | less or equal |
| `-gt` | greater than | | `-ge` | greater or equal |

**Never use `>` or `<` for numbers** in `[[ ]]` — those compare strings character by character, so `"9" > "10"`
is true. Use `(( ))` for arithmetic, which is even cleaner:

```bash
if (( age >= 18 )); then echo "adult"; fi
if (( count > 0 && count < 10 )); then echo "in range"; fi
```

---

## File tests (the ones you will use most)

| Test | True when |
|---|---|
| `-e path` | exists (file or folder) |
| `-f path` | exists and is a **regular file** |
| `-d path` | exists and is a **directory** |
| `-L path` | is a symbolic link |
| `-r` / `-w` / `-x` | you have read / write / execute permission |
| `-s path` | exists and is **non-empty** |
| `-O path` | you are the owner |
| `-G path` | you are in the file's group |
| `f1 -nt f2` | f1 is newer than f2 |
| `f1 -ot f2` | f1 is older than f2 |

```bash
if [[ -d "$dir" ]]; then
  echo "directory"
elif [[ -f "$dir" ]]; then
  echo "file"
else
  echo "does not exist"
fi
```

That `if/elif/else` is the pattern for "validate input before doing anything".

---

## Combining conditions

```bash
if [[ -f "$file" && -r "$file" ]]; then ... fi      # AND
if [[ "$a" == "x" || "$a" == "y" ]]; then ... fi    # OR
if [[ ! -d "$dir" ]]; then ... fi                    # NOT
if (( n > 0 && n % 2 == 0 )); then ... fi            # arithmetic AND
```

Nested conditions get unreadable fast. Prefer:
```bash
[[ -f "$file" ]] || { echo "missing: $file" >&2; exit 1; }
```
which is "or else do this" — a very common Bash idiom.

---

## `case`: many options, cleaner than many `elif`

```bash
case "$1" in
  start)
    echo "starting"
    ;;
  stop|halt|shutdown)
    echo "stopping"
    ;;
  restart)
    echo "restarting"
    ;;
  *.txt)
    echo "a text file"
    ;;
  *)
    echo "unknown: $1" >&2
    exit 1
    ;;
esac
```

`case` matches **patterns**, so `*.txt`, `[0-9]`, and `start|stop` all work. It is the right tool for
command-line subcommands and menu scripts.

---

## `&&` and `||` as short conditionals

```bash
$ mkdir -p /tmp/x && cd /tmp/x        # cd only if mkdir succeeded
$ [[ -f f ]] || echo "no file"        # echo only if the test failed
$ command1 && command2 || echo "failed"
```

`&&` = "and then" (runs only on success). `||` = "or else" (runs only on failure). This is terse and
idiomatic; use it for one-liners, and `if` for anything multi-line.

⚠️ `a && b || c` is **not** a true if/else: `c` runs if `a` succeeded but `b` failed. If you need exactly
one of two things, use `if`.

---

## The exit status (this is what conditions really test)

Every command returns a number: `0` = success, anything else = failure.

```bash
$ ls /etc > /dev/null; echo $?
0
$ ls /nope 2>/dev/null; echo $?
2
```

`if` does not test "truth" — it runs a command and checks its **exit code**. That is why you can write:
```bash
if grep -q "ERROR" "$log"; then
  echo "found errors"
fi
```
`grep -q` returns 0 when it matches. Every tool you use becomes a condition.

---

## Interactive menu (a classic exercise)

```bash
#!/usr/bin/env bash
set -euo pipefail

while true; do
  echo
  echo "1) Show date"
  echo "2) Show disk usage"
  echo "3) List home"
  echo "q) Quit"
  read -rp "Choice: " choice
  case "$choice" in
    1) date ;;
    2) df -h ;;
    3) ls -lah "$HOME" ;;
    q|Q) echo "bye"; break ;;
    *) echo "invalid choice" ;;
  esac
done
```

---

## Practice

Write `03-file-check.sh`:

1. Take a path as `$1`. If no argument, print usage and exit `1`.
2. If it does not exist, say so and exit `2`.
3. If it is a directory, say how many entries it contains.
4. If it is a regular file, say its size in bytes and whether it is readable/writable/executable.
5. If it is a symlink, say where it points.
6. Add the shebang, `set -euo pipefail`, and quotes everywhere.

Write `03-grade.sh`:

7. Take a numeric score 0–100 as `$1`.
8. Validate it is a number; reject anything else with exit `1`.
9. Print the grade: `A` ≥90, `B` ≥80, `C` ≥70, `D` ≥60, `F` otherwise.
10. Use `case` for a "retake required?" message: F → yes, D → maybe, else no.

<details>
<summary>Answer: 03-file-check.sh</summary>

```bash
#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <path>" >&2
  exit 1
fi

path="$1"

if [[ ! -e "$path" ]]; then
  echo "Not found: $path" >&2
  exit 2
fi

if [[ -L "$path" ]]; then
  echo "$path is a symlink to $(readlink "$path")"
fi

if [[ -d "$path" ]]; then
  count=$(find "$path" -maxdepth 1 -mindepth 1 | wc -l)
  echo "$path is a directory with $count entries"
elif [[ -f "$path" ]]; then
  size=$(stat -c %s "$path")
  echo "$path is a file, $size bytes"
  [[ -r "$path" ]] && echo "  readable"
  [[ -w "$path" ]] && echo "  writable"
  [[ -x "$path" ]] && echo "  executable"
else
  echo "$path is something else (device, socket, fifo)"
fi
```
</details>

<details>
<summary>Answer: 03-grade.sh</summary>

```bash
#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <score 0-100>" >&2
  exit 1
fi

score="$1"
if [[ ! "$score" =~ ^[0-9]+$ ]] || (( score < 0 || score > 100 )); then
  echo "Error: score must be an integer 0-100" >&2
  exit 1
fi

if   (( score >= 90 )); then grade=A
elif (( score >= 80 )); then grade=B
elif (( score >= 70 )); then grade=C
elif (( score >= 60 )); then grade=D
else                         grade=F
fi

echo "Score: $score -> Grade: $grade"

case "$grade" in
  F) echo "Retake required: yes" ;;
  D) echo "Retake required: maybe" ;;
  *) echo "Retake required: no" ;;
esac
```
</details>

## Cheat card

```bash
if [[ -f "$f" ]]; then ...; fi
if [[ -z "$s" ]]; then ...; fi
if [[ ! -d "$d" ]]; then ...; fi
if (( n > 0 )); then ...; fi
if [[ "$a" == *.log ]]; then ...; fi
if [[ "$l" =~ ^ERROR ]]; then ...; fi
[[ -f "$f" ]] || { echo "missing" >&2; exit 1; }
case "$1" in a) ;; b|c) ;; *) ;; esac
cmd && echo ok || echo fail
```

Next: `04-loops.md`.
