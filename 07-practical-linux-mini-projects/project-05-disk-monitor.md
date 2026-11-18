# Project 05 — Disk & Memory Monitor

**Difficulty:** ⭐⭐⭐ · **Time:** 1 h
**Skills:** `df`, `free`, thresholds, loops, exit codes, cron, logging

---

## Goal

Build `monitor.sh`: a script that checks disk and memory, prints warnings above a threshold, exits with a
code a monitoring system can use, and is safe to run from cron every 15 minutes.

This is the canonical "first cron job" and the most common way a Linux machine fails silently: the disk
fills up and everything stops.

---

## Requirements

1. Usage: `./monitor.sh [--disk PCT] [--mem PCT] [--quiet]`
2. Defaults: disk `85`, memory `90`.
3. Check every real filesystem (skip `tmpfs`, `devtmpfs`, `overlay` if you like).
4. Check memory using **available**, not `free` (Linux uses spare RAM as cache — `free` looks alarming
   when nothing is wrong).
5. Print one line per problem: `WARN: / is 91% full (4.2G free)`.
6. Exit `0` = all good, `1` = warning, `2` = usage error.
7. `--quiet`: print nothing when healthy (for cron), but still exit with the right code.
8. Log to `~/linux-lab/logs/monitor.log` when run with `--log`.
9. No `grep`/`awk` that depends on locale-specific column headers — use `df -P` for stable output.

---

## Step by step

### Step 1 — Setup

```bash
mkdir -p ~/linux-lab/projects/05-monitor ~/linux-lab/logs
cd ~/linux-lab/projects/05-monitor
df -P | head -5
free -m | head -3
```
Look at the actual output before writing any parsing code. Never write a parser from memory.

### Step 2 — Disk check

`df -P` guarantees one line per filesystem with a fixed field order:
```
Filesystem     1024-blocks    Used Available Capacity Mounted on
/dev/sda1         41020672 9830400  29077504      26% /
```
```bash
df -P -x tmpfs -x devtmpfs | tail -n +2 | while read -r fs total used avail pcent mount; do
  pct="${pcent%\%}"
  (( pct >= threshold )) || continue
  printf 'WARN: %s is %s%% full (%s KB free)\n' "$mount" "$pct" "$avail"
done
```
**The subshell trap:** variables set inside that `while` are lost after the pipe. Use process substitution
instead:

```bash
warn=0
while read -r fs total used avail pcent mount; do
  pct="${pcent%\%}"
  (( pct >= disk_threshold )) || continue
  printf 'WARN: %s is %s%% full (%s KB free)\n' "$mount" "$pct" "$avail"
  warn=1
done < <(df -P -x tmpfs -x devtmpfs | tail -n +2)
```
Now `warn` survives and you can `exit` with it.

### Step 3 — Memory check

```bash
read -r total used free shared buff avail <<< "$(free -m | awk '/^Mem:/ {print $2, $3, $4, $5, $6, $7}')"
pct=$(( used * 100 / total ))
```
Use `avail` for the *real* picture:
```bash
# percent actually unavailable:
used_pct=$(( (total - avail) * 100 / total ))
```
Document in your README why you chose `available` (it excludes reclaimable cache).

### Step 4 — Argument parsing

```bash
disk_threshold=85
mem_threshold=90
quiet=0
log=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --disk)  disk_threshold="${2:?}"; shift 2 ;;
    --mem)   mem_threshold="${2:?}"; shift 2 ;;
    --quiet) quiet=1; shift ;;
    --log)   log=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage; exit 2 ;;
  esac
done
```

### Step 5 — Validate the thresholds

```bash
[[ "$disk_threshold" =~ ^[0-9]+$ ]] && (( disk_threshold >= 1 && disk_threshold <= 100 )) \
  || { echo "invalid --disk value" >&2; exit 2; }
```
Do this for both. An invalid threshold that silently matches everything is worse than a crash.

### Step 6 — Quiet mode + exit code

```bash
if (( !warn && quiet )); then
  exit 0
fi
(( warn )) && exit 1
echo "OK: all filesystems below ${disk_threshold}%, memory below ${mem_threshold}%"
exit 0
```

---

## Proof it works

```bash
# Force a warning with a silly threshold
./monitor.sh --disk 1; echo "exit=$?"          # warns about everything, exit 1

# Healthy run
./monitor.sh --disk 99; echo "exit=$?"         # OK, exit 0

# Quiet mode is silent when healthy
./monitor.sh --disk 99 --quiet; echo "exit=$?" # no output, exit 0

# Bad input
./monitor.sh --disk abc; echo "exit=$?"        # exit 2

# Logging
./monitor.sh --disk 1 --log
cat ~/linux-lab/logs/monitor.log

# Fill a loopback filesystem to test for real (VM only)
dd if=/dev/zero of=/tmp/fill bs=1M count=100
# ... use a small mount to actually trigger a threshold
```

### Test the cron path

```bash
crontab -e
# add: */15 * * * * /home/student/linux-lab/projects/05-monitor/monitor.sh --quiet --log
crontab -l
# wait, or force it:
/bin/bash -c '...' # run the exact command manually first — cron has a minimal PATH
```

**The #1 cron failure:** cron runs with a minimal `PATH` (`/usr/bin:/bin`) and no your-shell environment.
Use absolute paths inside the script, or set `PATH` at the top:
```bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```
Test the script with `env -i` to simulate it:
```bash
env -i /bin/bash ./monitor.sh --disk 99 ; echo $?
```

---

## Stretch goals

1. `--alert-command "..."` that runs only when a threshold is crossed (webhook/email stub).
2. Check inode usage too (`df -i`) — a filesystem can be "full" at 0% data usage.
3. Track a baseline and warn about **rapid** growth (e.g. +10% in an hour) using a state file.
4. Add `--json` output for a monitoring agent.
5. Add a `--human` flag that prints bytes as GB with one decimal.

---

## Grading rubric

| Criterion | Points |
|---|---|
| Disk check works on all real filesystems | 20 |
| Memory check uses `available`, explained in README | 15 |
| Correct exit codes (0/1/2) | 20 |
| `--quiet` produces no output when healthy | 10 |
| Threshold validation | 10 |
| Runs correctly under cron-like minimal environment | 15 |
| No subshell variable bug | 10 |

**80+** = done.
