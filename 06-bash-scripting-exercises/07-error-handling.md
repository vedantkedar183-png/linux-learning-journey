# 07 — Error Handling: Scripts That Fail Loudly

A script that fails silently is worse than no script: it looks like it worked. This chapter is what
separates a hobby script from something you would put in production.

---

## Exit codes

Every process returns a number 0–255. `0` means success.

```bash
$ ls /etc > /dev/null; echo $?
0
$ ls /nope 2>/dev/null; echo $?
2
```

```bash
$?        # exit code of the previous command
exit 0    # success
exit 1    # generic failure
exit 2    # misuse of shell builtin / bad usage
exit 127  # command not found
exit 130  # terminated by Ctrl+C (128 + SIGINT)
```

Convention: any non-zero exit means failure, and the *specific* number can document *why*:
```bash
readonly E_USAGE=64
readonly E_NOFILE=66
[[ -f "$cfg" ]] || { echo "missing $cfg" >&2; exit $E_NOFILE; }
```

---

## `set -euo pipefail` — the three safety rails

```bash
#!/usr/bin/env bash
set -euo pipefail
```

| Flag | Effect | Why it matters |
|---|---|---|
| `-e` | exit on any command failure | stops before making a mess |
| `-u` | error on unset variables | catches typos like `$flie` |
| `-o pipefail` | a pipeline fails if **any** part fails | otherwise `false \| true` returns success |

Without `pipefail`, this silently succeeds:
```bash
set -e
false | true          # exit 0 — the failure was swallowed
set -o pipefail
false | true          # exit 1 — now it is caught
```

That is why you see `set -euo pipefail` at the top of nearly every serious script. Put it in all of yours
from today.

### `-e` has exceptions you must know

`set -e` does **not** trigger on:
- a command in an `if` / `while` condition
- a command in a `&&`/`||` list except the last
- `!` inverted commands
- any command in a pipeline except the last (unless `pipefail`)

So these are safe:
```bash
if grep -q x file; then ...; fi        # failure is expected and handled
grep -q x file || echo "not found"     # handled
```

And these will kill the script:
```bash
grep -q x file                          # if no match -> exit
n=$(grep -c x file)                     # same problem
```
Fix: `|| true`, or put it in a condition, or `set +e` around a block you explicitly handle.

---

## Reporting errors properly

```bash
die() {
  echo "ERROR: $*" >&2        # >&2 sends it to stderr, not stdout
  exit 1
}

[[ -d "$src" ]] || die "source directory not found: $src"
```

**Why stderr matters:** if your script pipes to a file, error messages on stdout pollute the data.
`2>/dev/null` should suppress noise, not your actual error.

```bash
./script.sh > out.txt            # stdout to file
./script.sh 2> err.txt           # errors to file
./script.sh > out.txt 2>&1       # both to file
```

---

## `trap`: clean up on exit (even on Ctrl+C)

Temp files left behind are a classic bug. `trap` runs a command when the script exits for **any** reason.

```bash
#!/usr/bin/env bash
set -euo pipefail

tmpdir=$(mktemp -d)
cleanup() {
  rm -rf -- "$tmpdir"
}
trap cleanup EXIT

# ... work with "$tmpdir" ...
```

Signals you can trap:

| Trap | Fires on |
|---|---|
| `EXIT` | any exit (normal, error, trapped signal) |
| `ERR` | a command fails (with `set -e`) |
| `INT` | `Ctrl+C` |
| `TERM` | `kill` |
| `HUP` | terminal closed |

```bash
trap 'echo "interrupted" >&2; exit 130' INT
trap 'echo "failed at line $LINENO" >&2' ERR
trap 'rm -f "$lock"' EXIT
```

---

## Locking: prevent two copies running at once

Two backups running at the same time can corrupt data. The standard tool is `flock`:

```bash
#!/usr/bin/env bash
set -euo pipefail

exec 9>/var/lock/backup.lock
if ! flock -n 9; then
  echo "another backup is running" >&2
  exit 0
fi

# ... only one instance ever reaches here ...
```
`-n` means "do not wait". Without `-n`, the second copy waits its turn (also often correct).

---

## Logging

```bash
log() {
  printf '[%s] [%s] %s\n' "$(date '+%F %T')" "$1" "$2"
}
log INFO  "starting backup"
log WARN  "skipping empty file"
log ERROR "tar failed" >&2
```

Or to a file **and** the screen:
```bash
exec > >(tee -a "$LOG_FILE") 2>&1
```
This redirects everything from that point on to both the file and the terminal. Very handy for cron jobs
where you want a record.

---

## Handling a missing dependency

```bash
need() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}
need tar
need rsync
need gzip
```
Check at the start, not in the middle after half the work is done.

---

## The complete template

```bash
#!/usr/bin/env bash
#
# NAME: backup.sh
# USAGE: ./backup.sh <source-dir> [dest-dir]
# DESC: Creates a dated .tar.gz of a directory, verifies it, and cleans up.
#
set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME=$(basename "$0")
readonly STAMP=$(date +%Y%m%d-%H%M%S)

log()  { printf '[%s] %s\n' "$(date +%T)" "$*"; }
warn() { printf '[%s] WARN: %s\n' "$(date +%T)" "$*" >&2; }
die()  { printf '[%s] ERROR: %s\n' "$(date +%T)" "$*" >&2; exit 1; }
usage(){ printf 'Usage: %s <source-dir> [dest-dir]\n' "$SCRIPT_NAME"; }

need() { command -v "$1" >/dev/null 2>&1 || die "missing dependency: $1"; }

main() {
  [[ $# -ge 1 ]] || { usage; exit 64; }
  local src="$1"
  local dest="${2:-$HOME/backups}"

  [[ -d "$src"  ]] || die "source not a directory: $src"
  mkdir -p "$dest" || die "cannot create $dest"

  need tar
  local archive="$dest/$(basename "$src")-$STAMP.tar.gz"

  log "creating $archive"
  tar -czf "$archive" -C "$(dirname "$src")" "$(basename "$src")" \
    || die "tar failed"

  log "verifying archive"
  tar -tzf "$archive" >/dev/null || die "archive is corrupt: $archive"

  local size
  size=$(du -h "$archive" | cut -f1)
  log "done: $archive ($size)"
}

main "$@"
```

Notice: every function has one job, failures go through `die`, dependencies are checked up front,
the archive is verified, and usage errors use a distinct exit code.

---

## Practice

Write `07-safe-backup.sh`:

1. Copy the template above and make it work.
2. Run it with no arguments — which exit code? Which message?
3. Run it on a non-existent directory — which exit code?
4. Run it on a real directory and confirm the archive exists and verifies.
5. Temporarily rename `tar` (or use a fake `PATH`) to simulate a missing dependency. Does it fail *before*
   doing work?
6. Add a `trap` that removes a partial archive if `tar` fails. Test by making `$dest` unwritable.
7. Add a lock with `flock`. Test by running two copies at once.
8. Add logging to `~/backups/backup.log` while still showing output on screen.

Then write `07-args.sh`:

9. Exit `64` on bad usage, `66` on missing input, `0` on success.
10. Validate that an argument looks like a number with a regex and `die` if not.
11. Print the elapsed time of a `sleep 2` using `SECONDS`.
12. Explain: why is `exit 0` at the end of a script that already succeeded redundant but harmless?

<details>
<summary>Answers / hints</summary>

2. Usage error → exit `64`, with the usage text.
3. `die` → exit `1` (or `66` if you added the code). Use a specific code if you want scripts to react.
5. `need tar` must be called **before** creating the archive — otherwise you discover the problem after
   writing half a file.
6.
```bash
partial=0
trap '[[ $partial -eq 1 ]] && rm -f -- "$archive"' EXIT
partial=1
tar -czf "$archive" ... || die "tar failed"
partial=0
```
7.
```bash
exec 9>"$dest/.backup.lock"
flock -n 9 || { echo "already running" >&2; exit 0; }
```
8.
```bash
exec > >(tee -a "$HOME/backups/backup.log") 2>&1
```
11. `SECONDS` is a builtin counter: `start=$SECONDS; sleep 2; echo $((SECONDS-start))`.
12. Redundant but harmless — the last command's status is already the script's status; being explicit
    documents intent and protects you if someone appends code later.
</details>

## Cheat card

```bash
set -euo pipefail
exit 0 / exit 1 / exit 64
die() { echo "ERROR: $*" >&2; exit 1; }
trap cleanup EXIT
trap 'echo interrupted >&2; exit 130' INT
tmp=$(mktemp -d)
flock -n 9          # with exec 9>lockfile
command -v tar >/dev/null || die "no tar"
"$@" | while ...        # remember subshell scope
```

Next: `08-common-scripts.md` — five complete scripts to read and steal from.
