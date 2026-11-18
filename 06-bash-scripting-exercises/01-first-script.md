# 01 — Your First Script

## What a script is

A plain text file with commands in it. When you run it, the shell executes each line in order, exactly as
if you had typed them.

```bash
$ cat hello.sh
#!/usr/bin/env bash
echo "Hello, Linux!"
echo "Today is $(date)"
```

Two new things there: the **shebang** and `$(...)`.

---

## The shebang: `#!/usr/bin/env bash`

The first line, starting with `#!`, tells the kernel **which interpreter** to use.

```bash
#!/usr/bin/env bash     # recommended: find bash in PATH (works everywhere)
#!/bin/bash             # also fine, hard-coded path
#!/bin/sh               # POSIX shell (more compatible, fewer features)
#!/usr/bin/env python3  # not bash at all — the mechanism is generic
```

Why `env bash`? Because `bash` might be in `/usr/local/bin` on some systems. `env` finds it through `PATH`.
It is the portable choice.

Without a shebang, the kernel does not know what to do with the file (or falls back to `sh`, which may be
`dash` and behave differently). **Always include it.**

---

## Make it runnable

```bash
$ cd ~/linux-lab/scripts
$ nano hello.sh
# type the script, save with Ctrl+O, Enter, Ctrl+X

$ chmod +x hello.sh
$ ./hello.sh
Hello, Linux!
Today is Mon Nov 16 10:30:00 IST 2026
```

Three ways to run a script, and why they differ:

| Command | What happens |
|---|---|
| `./hello.sh` | kernel reads the shebang, uses that interpreter. Needs `+x`. **Normal way.** |
| `bash hello.sh` | you choose the interpreter explicitly. `+x` not needed. Good for testing. |
| `source hello.sh` or `. hello.sh` | runs **in your current shell** — variables and `cd` persist. |

`source` is for loading configuration (`source ~/.bashrc`), not for running programs. A script that ends
with `exit` will close your terminal if you `source` it. That surprises everyone once.

---

## Quoting: the #1 source of bash bugs

```bash
$ name="Linux"
$ echo "Hello, $name"      # double quotes: variables ARE expanded
Hello, Linux
$ echo 'Hello, $name'      # single quotes: everything is literal
Hello, $name
$ echo Hello,   $name      # unquoted: word splitting and globbing happen
Hello, Linux
```

| Syntax | Expands variables? | Allows spaces in one value? | Use for |
|---|---|---|---|
| `"double"` | yes | yes | most things — **default choice** |
| `'single'` | no | yes | literal text, regex, `$` that must stay |
| `unquoted` | yes | **no** (splits on spaces) | almost never |
| `` `backticks` `` | yes | — | legacy; use `$(...)` instead |

**Rule of thumb: put double quotes around every variable you use.** `"$file"`, not `$file`. Otherwise a
filename with a space breaks your script.

```bash
$ file="my report.txt"
$ rm $file          # tries to delete "my" and "report.txt" !
$ rm "$file"        # correct
```

This is why serious scripts look like `"${HOME}/backups/${name}.tar.gz"` — quotes everywhere.

---

## Command substitution and arithmetic

```bash
$ today=$(date +%F)             # run a command, capture its output
$ echo "$today"
2026-11-16

$ count=$(ls | wc -l)
$ echo "There are $count files."

$ echo $((2 + 3))               # arithmetic with $(( ))
5
$ files=5
$ echo $((files * 2))
10
```

Note `$(...)` not backticks. Backticks work but cannot be nested cleanly and are easy to misread.

---

## Comments and readability

```bash
#!/usr/bin/env bash
# backup-db.sh — dump the database and compress it
# Usage: ./backup-db.sh [output-dir]
# Author: you, 2026-11-16

set -euo pipefail      # explained in chapter 7 — add it from day one

# --- configuration ---
DB_NAME="appdb"
BACKUP_DIR="${1:-$HOME/backups}"     # use $1 if given, else a default

# --- main ---
echo "Backing up $DB_NAME to $BACKUP_DIR"
```

Comments explain **why**, not what. `# increment i` above `i=$((i+1))` is noise. `# retry because the API
is flaky` is useful.

---

## Your turn

Create `hello.sh`:

```bash
#!/usr/bin/env bash
echo "Hello, Linux!"
echo "I am $(whoami) and I am in $(pwd)"
echo "The date is $(date '+%A %d %B %Y')"
```

Then:

1. Run it with `./hello.sh`. If you get "Permission denied", what did you forget?
2. Run it with `bash hello.sh`. Does it work without `+x`? Why?
3. Change the echo to use **single quotes**. What happens to `$(whoami)` and why?
4. Add a line that prints the kernel version using `$(uname -r)`.
5. Add a line that prints the number of files in the current directory using `$(ls | wc -l)`.
6. Deliberately break it: remove the closing `"` on one line. Run `bash -n hello.sh`. What does the syntax
   check say?
7. Run `file hello.sh`. What does it report?
8. Run `ls -l hello.sh` and identify the executable bit.

<details>
<summary>Answers</summary>

1. `chmod +x hello.sh`.
2. Yes — `bash` is the interpreter, so the file does not need to be executable. The kernel never reads the
   shebang in this case.
3. Single quotes prevent expansion, so it prints the literal `$(whoami)` text.
6. `bash -n` reports something like `unexpected EOF while looking for matching '"'`.
7. `Bourne-Again shell script, ASCII text executable`.
</details>

---

## Common first-script errors

| Error | Cause | Fix |
|---|---|---|
| `Permission denied` | not executable | `chmod +x file.sh` |
| `command not found` when running `hello.sh` | `.` is not in `PATH` | use `./hello.sh` |
| `bad interpreter: No such file or directory` | wrong shebang path, or **Windows line endings** | fix shebang; run `dos2unix file.sh` |
| `syntax error near unexpected token 'fi'` | missing `then`/`if`, or CRLF line endings | `bash -n file.sh`, check line endings |
| Script does nothing | typo in filename, or empty file | `cat` the file, check `bash -x` |
| `$'\r': command not found` | **CRLF** from Windows | `sed -i 's/\r$//' file.sh` |

**CRLF is worth calling out.** If you edit scripts on Windows (Notepad, VS Code with CRLF) and then run
them in WSL, every line ends with an invisible `\r` that bash treats as part of the command. Fix:
```bash
$ sed -i 's/\r$//' script.sh      # remove CR
$ file script.sh                  # should say "ASCII text", not "with CRLF line terminators"
```
Set your editor to use LF for `.sh` files and never think about it again.

---

## Debugging tools

```bash
$ bash -n script.sh     # syntax check only (no execution)
$ bash -x script.sh     # trace: print each command as it runs, prefixed with +
$ bash -v script.sh     # print each line before running
$ shellcheck script.sh  # best-practice linter (highly recommended)
```

`bash -x` is the single most useful debugging tool. Add `set -x` temporarily at the top of a section, or run
`bash -x ./script.sh`, and watch the values as variables change.

---

## Mini challenge

Write `about-me.sh` that prints:

```
User:      <your username>
Home:      <your home folder>
Shell:     <your shell>
Kernel:    <kernel version>
Uptime:    <up X days, Y hours>
Scripts:   <number of .sh files in ~/linux-lab>
```

Every value must come from a command substitution, and every variable must be quoted where used.
Hint: `uptime -p`, `find ~/linux-lab -name "*.sh" | wc -l`.

Next: `02-variables-and-input.md`.
