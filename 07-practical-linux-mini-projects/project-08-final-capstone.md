# Project 08 — Final Capstone: Personal Ops Toolkit

**Difficulty:** ⭐⭐⭐⭐⭐ · **Time:** 3 h
**Skills:** everything from the whole course

---

## Goal

Combine projects 01–06 into **one installable toolkit**: a folder with small commands, a shared library,
a single entry point, a config file, logging, and tests. Then document it like a real project.

This is the piece you show at the end of the class. It should be small enough to explain in 5 minutes and
solid enough that every command works on a fresh machine.

---

## The deliverable

```
ops-toolkit/
├── bin/
│   ├── ops                 # the single entry point (subcommands)
│   ├── sysreport.sh
│   ├── backup.sh
│   ├── loganalyze.sh
│   ├── monitor.sh
│   └── netcheck.sh
├── lib/
│   └── common.sh           # shared functions: log, die, need, usage, confirm
├── etc/
│   └── ops.conf            # defaults: backup dir, thresholds, log path
├── tests/
│   └── run-tests.sh        # tests every command
├── install.sh              # copies to ~/bin, sets permissions, checks deps
└── README.md
```

---

## Requirements

### 1. One entry point
```bash
$ ops help
Usage: ops <command> [args]

Commands:
  sysreport            system summary
  backup <dir>         verified backup
  log <file>           analyse a log
  monitor              disk/memory check
  netcheck             network health

$ ops sysreport
$ ops backup ~/linux-lab
$ ops log /var/log/syslog --top 5
```
Implementation sketch:
```bash
#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"

cmd="${1:-help}"
shift || true
case "$cmd" in
  sysreport) exec "$SCRIPT_DIR/sysreport.sh" "$@" ;;
  backup)    exec "$SCRIPT_DIR/backup.sh" "$@" ;;
  log)       exec "$SCRIPT_DIR/loganalyze.sh" "$@" ;;
  monitor)   exec "$SCRIPT_DIR/monitor.sh" "$@" ;;
  netcheck)  exec "$SCRIPT_DIR/netcheck.sh" "$@" ;;
  help|-h|--help) usage ;;
  *) die "unknown command: $cmd (try: ops help)" ;;
esac
```

### 2. Shared library (`lib/common.sh`)
Every script sources it and gets the same behaviour:
```bash
log()  { printf '[%s] %s\n' "$(date +%T)" "$*"; }
warn() { printf '[%s] WARN: %s\n' "$(date +%T)" "$*" >&2; }
die()  { printf '[%s] ERROR: %s\n' "$(date +%T)" "$*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "missing: $1"; }
confirm() { read -rp "$1 [y/N] " a; [[ "$a" == [yY] ]]; }
```
**Guard against double-sourcing:**
```bash
[[ -n "${OPS_COMMON_LOADED:-}" ]] && return 0
readonly OPS_COMMON_LOADED=1
```

### 3. Config file (`etc/ops.conf`)
```bash
# ops-toolkit defaults
OPS_LOG_DIR="${OPS_LOG_DIR:-$HOME/linux-lab/logs}"
OPS_BACKUP_DIR="${OPS_BACKUP_DIR:-$HOME/backups}"
OPS_DISK_THRESHOLD="${OPS_DISK_THRESHOLD:-85}"
OPS_MEM_THRESHOLD="${OPS_MEM_THRESHOLD:-90}"
```
Precedence, documented: **environment > config file > built-in default**.

### 4. Logging
Every command appends to `$OPS_LOG_DIR/ops.log` with a timestamp and the command name. Errors also go to
stderr. Passwords never go to the log.

### 5. Idempotent installer
```bash
#!/usr/bin/env bash
set -euo pipefail
# copies bin/* to ~/bin, chmod +x, checks dependencies, creates ~/bin if missing,
# warns if ~/bin is not in PATH
```
Must be safe to run twice.

### 6. Tests (`tests/run-tests.sh`)
At least one assertion per command. Simple is fine:
```bash
assert_eq() {
  [[ "$1" == "$2" ]] && echo "ok: $3" || { echo "FAIL: $3 (got '$1', want '$2')"; fails=$((fails+1)); }
}
```
Test: exit codes, help output, a real backup + verification, a monitor threshold run, a netcheck against
`127.0.0.1`, a log analysis against a fixture file.

### 7. README
Must contain: what it is, install, usage with examples, config, dependencies, design decisions, known
limitations, and a short "what I learned" section.

---

## Step by step

1. **Create the skeleton** (folders + empty files + `chmod +x`). Commit.
2. **Write `lib/common.sh`.** Make `ops help` work with a stub `usage`.
3. **Move project 01 in** as `sysreport.sh`. Fix its paths so it works from any directory:
   `readonly SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)`.
4. **Move projects 02, 03, 05, 06 in.** One at a time, testing after each.
5. **Add config + logging.** Make the thresholds come from `ops.conf`, not hard-coded numbers.
6. **Write `install.sh`** and test it in a fresh shell.
7. **Write `tests/run-tests.sh`.** Run it. Fix what fails.
8. **Write the README last**, when you know what you actually built.
9. **Commit** with a clear message. Tag it `v1.0`.

---

## Proof it works (the acceptance test)

Run these on a fresh shell, from a directory that is not the toolkit folder:

```bash
$ ops help
$ ops sysreport | head -5
$ ops backup ~/linux-lab
$ tar -tzf ~/backups/linux-lab-*.tar.gz | head -3
$ ops log /var/log/syslog --top 3
$ ops monitor --disk 1; echo "exit=$?"        # warning, exit 1
$ ops monitor --disk 99; echo "exit=$?"       # ok, exit 0
$ ops netcheck | tail -3
$ ops nonsense; echo "exit=$?"                # clear error, non-zero
$ bash tests/run-tests.sh                     # all ok
$ ls -l ~/bin/ops                             # installed and executable
$ cat ~/linux-lab/logs/ops.log | tail -5      # actions logged
```

**The real test:** hand the folder to a classmate (or a fresh VM) and see if your README is enough to
install and run it. Whatever they ask you is missing from the README.

---

## Design questions you must answer in the README

1. Why one entry point instead of five separate commands in `PATH`?
2. Why a shared `lib/common.sh` instead of copying `die()` into each script?
3. How do you set `SCRIPT_DIR` and why is `$(dirname "$0")` alone not enough?
4. What is your config precedence, and why?
5. Where do logs go, and what happens if the log dir does not exist?
6. How do you avoid two backups running at once?
7. What are the three riskiest commands in your toolkit, and what protects against them?

---

## Grading rubric (100 points)

| Section | Points |
|---|---|
| `ops` entry point with help and subcommands | 10 |
| All five commands work from any directory | 20 |
| `lib/common.sh` shared by all scripts (no duplication) | 10 |
| Config file with documented precedence | 10 |
| Logging to a file, no secrets logged | 10 |
| `install.sh` idempotent, checks dependencies | 10 |
| `tests/run-tests.sh` with real assertions | 15 |
| README complete, including design answers | 15 |

**85+ = portfolio-ready.** 100 means a classmate could install it from your README alone.

---

## After the capstone

You have now done, at least once, everything a junior Linux admin is expected to do:

- navigate and manage a filesystem safely
- reason about users, groups, and permissions
- inspect processes, services, and logs
- diagnose a network problem in a sensible order
- write Bash that fails loudly and cleans up after itself
- build something with tests and documentation

Keep the toolkit. Add a command whenever you do the same manual task a third time. That habit is how
sysadmins are made.
