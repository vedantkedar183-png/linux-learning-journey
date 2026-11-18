# Project 03 — Log Analyzer

**Difficulty:** ⭐⭐ · **Time:** 1.5 h
**Skills:** `grep`, `sed`, `awk`, `sort | uniq -c`, regex, reporting

---

## Goal

Build `loganalyze.sh` that reads a log file and produces answers a human actually needs: how many errors,
which hours were worst, what the top messages are, and which IPs are hammering the server.

This is the task you will be handed in any job that involves a server.

---

## Requirements

1. Usage: `./loganalyze.sh <logfile> [--top N]`.
2. Default `N` = 10.
3. Exit `64` on bad usage, `66` if the file is unreadable.
4. Produce these sections:
   - **Summary**: total lines, file size, first and last timestamp
   - **Severity counts**: ERROR / WARNING / INFO / DEBUG (case-insensitive)
   - **Top N messages** with timestamps stripped and duplicates counted
   - **Errors per hour** (from the timestamp), sorted by hour
   - **Top N client IPs** (first field, only if it looks like an IP)
   - **Slowest requests** (if the log is an nginx-style access log — optional)
5. Must work on a **generic** log, not just one format: skip lines it cannot parse instead of crashing.
6. Output to stdout; errors to stderr.
7. Exit `1` if any ERROR lines were found, `0` otherwise (so a monitor can react).

---

## Step by step

### Step 1 — Make a realistic test log

Do not test on `/var/log/syslog` alone — build a log with known answers so you can verify your script.

```bash
mkdir -p ~/linux-lab/projects/03-log-analyzer && cd $_
cat > sample.log <<'EOF'
2026-11-16 09:00:01 INFO  app started
2026-11-16 09:00:05 INFO  user alice logged in
2026-11-16 09:01:11 WARNING disk usage 81%
2026-11-16 09:02:00 ERROR database connection timeout
2026-11-16 09:02:01 ERROR database connection timeout
2026-11-16 09:03:00 INFO  request /index 200
2026-11-16 09:04:12 ERROR payment service unavailable
2026-11-16 10:00:00 INFO  user bob logged in
2026-11-16 10:01:00 WARNING high memory
2026-11-16 10:02:00 ERROR database connection timeout
2026-11-16 10:03:00 INFO  request /api 200
2026-11-16 10:04:00 DEBUG cache hit ratio 0.92
EOF
```
Known answers: 12 lines, 4 ERROR, 2 WARNING, 5 INFO, 1 DEBUG, 3× "database connection timeout".

### Step 2 — Count severities

```bash
grep -ci error sample.log
```
But `set -e` kills you when the count is 0:
```bash
grep -ci error "$log" || true
```
Write a `count()` helper.

### Step 3 — Top messages

Strip the timestamp, then count:
```bash
sed -E 's/^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9:]+ +//' "$log" | sort | uniq -c | sort -rn | head -n "$N"
```
Test the `sed` alone first. If the timestamps are gone, you got it right.

### Step 4 — Errors per hour

```bash
grep -i error "$log" | cut -d' ' -f1,2 | cut -d: -f1 | sort | uniq -c
```
Careful: this assumes the timestamp is the first two fields. Document that assumption in your README, or
make it configurable.

### Step 5 — Top IPs

```bash
awk '$1 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ {print $1}' "$log" | sort | uniq -c | sort -rn | head -n "$N"
```
The regex filter means ordinary log lines are skipped instead of producing garbage.

### Step 6 — Argument parsing with a flag

```bash
top=10
while [[ $# -gt 0 ]]; do
  case "$1" in
    --top) top="${2:?--top needs a number}"; shift 2 ;;
    -*)    echo "unknown option: $1" >&2; exit 64 ;;
    *)     log="$1"; shift ;;
  esac
done
[[ -n "${log:-}" ]] || { usage; exit 64; }
[[ -r "$log" ]] || { echo "cannot read: $log" >&2; exit 66; }
```

---

## Proof it works

On `sample.log`, your script must report:

```bash
$ ./loganalyze.sh sample.log
total lines:   12
ERROR:         4
WARNING:       2
INFO:          5
DEBUG:         1

top messages:
   3 database connection timeout
   1 user bob logged in
   ...

errors per hour:
   2 2026-11-16 09
   1 2026-11-16 10
```

Then:
```bash
$ ./loganalyze.sh sample.log > /dev/null; echo "exit=$?"     # 1 (errors present)
$ grep -v ERROR sample.log > clean.log
$ ./loganalyze.sh clean.log > /dev/null; echo "exit=$?"      # 0
$ ./loganalyze.sh; echo $?                                   # 64
$ ./loganalyze.sh /nope; echo $?                             # 66
$ ./loganalyze.sh sample.log --top 2                          # only 2 messages
```

Real-world test (read-only):
```bash
$ ./loganalyze.sh /var/log/syslog --top 5
```
It should not crash on lines in a completely different format. That is the "generic log" requirement.

---

## Stretch goals

1. `--since "2026-11-16 09:30"` filtering.
2. `--json` output.
3. Detect and report the **first and last timestamp** by parsing, not by assuming position.
4. Write a `summary.txt` with only the counts (for monitoring).
5. Add a `--watch` mode that re-runs every 5 seconds.
6. Handle nginx access logs: parse status codes and report 4xx/5xx rates.

---

## Grading rubric

| Criterion | Points |
|---|---|
| All 5 required sections present and correct on `sample.log` | 30 |
| Top messages correctly strip timestamps | 15 |
| Exit codes correct (0/1/64/66) | 15 |
| Works on a foreign log format without crashing | 15 |
| `--top N` flag parses and validates | 10 |
| README states assumptions (timestamp position, format) | 15 |

**80+** = done.
