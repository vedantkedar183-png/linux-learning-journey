# Project 01 — System Report Generator

**Difficulty:** ⭐ · **Time:** 45 min
**Skills:** `awk`, `df`, `free`, `ps`, `printf`, functions, output formatting

---

## Goal

Write `sysreport.sh` that prints a clean, aligned system report to the terminal, and optionally to a file.
This is the script every sysadmin writes first, because it answers "what is this machine doing?" in one
command.

---

## Requirements

1. `set -euo pipefail` and a header comment block.
2. Helper functions `line()` and `section()`.
3. Report these sections:
   - **SYSTEM**: hostname, kernel, OS name, uptime, current user
   - **CPU/MEM**: core count, load average, memory used/total, swap used/total
   - **DISK**: one line per real filesystem (skip `tmpfs`, `devtmpfs`) with use%
   - **TOP 5 BY MEMORY**: user, %MEM, command
   - **NETWORK**: IPv4 address, default gateway, DNS server
   - **LISTENING PORTS**: count + the first 5
4. Accept one optional argument: an output file. If given, write to the file **and** the terminal.
5. Exit `0` on success. If the output file cannot be written, exit non-zero with a clear message.
6. No hard-coded absolute paths except `/proc` and `/etc` sources.

---

## Step by step

### Step 1 — Skeleton
```bash
mkdir -p ~/linux-lab/projects/01-system-report
cd ~/linux-lab/projects/01-system-report
nano sysreport.sh
```
Start with:
```bash
#!/usr/bin/env bash
set -euo pipefail

line()    { printf '%-14s %s\n' "$1" "$2"; }
section() { printf '\n== %s ==\n' "$1"; }

section "SYSTEM"
line "Host:" "$(hostname)"
```
Run it. See the output. **Only then** add the next section.

### Step 2 — Discover each value

Don't guess commands. Find one, check it, then embed it:

| Value | Find it with |
|---|---|
| OS name | `cat /etc/os-release` |
| Uptime | `uptime -p` |
| Cores | `nproc` |
| Load | `cat /proc/loadavg` |
| Memory | `free -h` |
| Disk | `df -h` / `df -P` |
| Top processes | `ps aux --sort=-%mem \| head -6` |
| IPv4 | `hostname -I` |
| Gateway | `ip r` |
| DNS | `cat /etc/resolv.conf` |
| Ports | `ss -tln` |

### Step 3 — Format with `awk`

For memory:
```bash
free -h | awk '/^Mem:/ {print $3" used / "$2" total"}'
```
For disk, loop over `df -P` (the `-P` flag gives stable one-line-per-filesystem output):
```bash
df -P -x tmpfs -x devtmpfs | tail -n +2 | while read -r fs size used avail pcent mount; do
  printf '%-22s %5s used of %-6s (%s)\n' "$fs" "$used" "$size" "$pcent"
done
```

### Step 4 — Optional file output
```bash
out="${1:-}"
if [[ -n "$out" ]]; then
  exec > >(tee -a "$out") 2>&1
fi
```
`exec` here redirects **everything** that follows. Put it near the top, after argument validation.

### Step 5 — Test the edges
- No argument → terminal only.
- With a writable path → file created and screen shows output.
- With `/root/x.txt` → fails clearly (no sudo).
- On a machine without `ip` → does it crash? Add `|| echo unknown`.

---

## Proof it works

```bash
$ ./sysreport.sh
$ ./sysreport.sh report.txt && head -5 report.txt
$ ./sysreport.sh /root/nope.txt; echo "exit=$?"
```

Expected: three clean sections of output; `report.txt` contains the same text; the last command prints a
non-zero exit and an error, not a stack of shell noise.

---

## Stretch goals

1. Add a `--json` mode that prints machine-readable output (build it with `printf`, do not install `jq`).
2. Add colour when output is a terminal (`[[ -t 1 ]] && ...`).
3. Add a `--watch N` mode that refreshes every N seconds.
4. Add a warning line when any filesystem is over 85% or load is above the core count.

---

## Grading rubric

| Criterion | Points |
|---|---|
| Runs with no arguments and prints all 6 sections | 25 |
| Output is aligned and readable (`printf`, not messy `echo`) | 15 |
| Correct values (you verified each command separately) | 20 |
| Optional file output works, including failure case | 15 |
| Handles missing/failing commands gracefully | 15 |
| `README.md` explains usage and includes a sample output | 10 |

**80+** = done. Keep this script; project 08 reuses it.
