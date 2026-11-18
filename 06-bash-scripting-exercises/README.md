# 06 — Bash Scripting Exercises

A **script** is a text file of commands that Linux runs for you. That is the whole idea. Everything else is
just making the script smarter: variables, decisions, loops, functions, and error handling.

Why bother? Because you will type the same 8 commands again next week. A script turns 8 commands into one
command, forever, with fewer mistakes.

| Chapter | Topic | Time |
|---|---|---|
| `01-first-script.md` | shebang, `chmod +x`, running, quoting | 25 min |
| `02-variables-and-input.md` | variables, `read`, arguments, arithmetic | 30 min |
| `03-conditionals.md` | `if`, `[[ ]]`, file tests, `case` | 35 min |
| `04-loops.md` | `for`, `while`, `read` loop, `break`/`continue` | 35 min |
| `05-functions-and-arrays.md` | functions, `local`, arrays, associative arrays | 30 min |
| `06-text-processing.md` | `grep`, `cut`, `awk`, `sed`, `sort` in scripts | 35 min |
| `07-error-handling.md` | exit codes, `set -euo pipefail`, `trap`, logging | 30 min |
| `08-common-scripts.md` | five ready-to-read real scripts | 30 min |

Then: `exercises/` (starters with TODOs) and `solutions/` (finished, annotated).

---

## Setup

```bash
$ cd ~/linux-lab
$ mkdir -p scripts exercises
$ cd scripts
```

Use `~/linux-lab/scripts` for your own practice. The `exercises/` folder in this project contains starter
templates — copy them to `~/linux-lab/scripts` and fill them in.

```bash
$ cp -r "D:\Linux(project)\06-bash-scripting-exercises\exercises" ~/linux-lab/ 2>/dev/null || true
# in WSL your Windows path is under /mnt/c or /mnt/d:
$ cp -r /mnt/d/Linux\(project\)/06-bash-scripting-exercises/exercises ~/linux-lab/ 2>/dev/null || true
```

If copying is awkward, just create the files yourself with `nano`. Typing them is better practice anyway.

---

## The rules of this module

1. **Type the code.** Do not copy-paste while learning. Muscle memory matters for syntax.
2. **Run it after every change.** Small steps, always working.
3. **Read the error message.** `syntax error near unexpected token` tells you the line and usually the
   reason (a missing `fi`, `done`, or quote).
4. **Run `bash -n script.sh`** to check syntax without executing.
5. **Run `shellcheck script.sh`** if installed (`sudo apt install shellcheck`). It catches real bugs and
   teaches you the idioms.

---

## The five-line checklist for every script

```bash
#!/usr/bin/env bash        # 1. correct shebang
set -euo pipefail          # 2. fail fast, catch typos in variables
# comments explaining what it does and how to run it
main() { ... }             # 3. one entry point (for anything longer than 20 lines)
main "$@"                  # 4. pass arguments through
```

5. `chmod +x script.sh` so it can run as `./script.sh`.

You will see exactly where each line comes from as you progress. By chapter 7 they will feel obvious.

---

## Naming and house rules (the ones professionals use)

| Rule | Why |
|---|---|
| `.sh` for Bash scripts | editors and `file` can identify them |
| lowercase-with-dashes names | `backup-db.sh`, not `Backup DB Final v2.sh` |
| no spaces in script names | spaces cause endless quoting bugs |
| scripts you run often go in `~/bin` | add `~/bin` to `PATH` |
| one script = one job | easier to test and reuse |
| exit `0` on success, non-zero on failure | lets other tools detect failure |
| never hard-code absolute paths without a reason | makes the script portable |

---

## How this module is graded (by you)

At the end you should be able to write these **without looking**:

- a script that takes a filename argument and tells you if it exists, is a file, or is a directory
- a script that loops over all `.log` files and prints their line counts
- a script that creates a dated backup with `tar` and refuses to run if the source is missing
- a script with `set -euo pipefail`, a `usage()` function, and a `trap` that cleans up temp files

Those four cover 90% of real Linux automation.
