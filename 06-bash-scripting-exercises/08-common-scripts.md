# 08 — Five Complete Scripts to Read and Steal From

Reading finished, well-written scripts is the fastest way to improve. Each one below is complete, tested
logic, and full of comments. Copy them, run them, break them, extend them.

Save them in `~/linux-lab/scripts/`, `chmod +x`, and run.

---

## 1. `sysinfo.sh` — a system report

```bash
#!/usr/bin/env bash
#
# sysinfo.sh — print a quick system summary
# Usage: ./sysinfo.sh
#
set -euo pipefail

# ---- helpers -------------------------------------------------------------
line() { printf '%-14s %s\n' "$1" "$2"; }
section() { printf '\n== %s ==\n' "$1"; }

# ---- header --------------------------------------------------------------
section "SYSTEM"
line "Hostname:"  "$(hostname)"
line "Kernel:"    "$(uname -r)"
line "OS:"        "$( . /etc/os-release 2>/dev/null && echo "${PRETTY_NAME:-unknown}" )"
line "Uptime:"    "$(uptime -p 2>/dev/null || uptime)"
line "Users:"     "$(who | wc -l) logged in"

# ---- CPU / memory --------------------------------------------------------
section "CPU & MEMORY"
line "Cores:"     "$(nproc)"
line "Load:"      "$(cut -d' ' -f1-3 /proc/loadavg)"
line "Memory:"    "$(free -h | awk '/^Mem:/ {print $3" used / "$2" total"}')"
line "Swap:"      "$(free -h | awk '/^Swap:/ {print $3" used / "$2" total"}')"

# ---- disk ----------------------------------------------------------------
section "DISK"
while IFS= read -r row; do
  printf '%s\n' "$row"
done < <(df -h --output=source,size,used,avail,pcent,target 2>/dev/null | grep -v tmpfs || df -h)

# ---- top processes -------------------------------------------------------
section "TOP 5 BY MEMORY"
ps aux --sort=-%mem | awk 'NR==1 || NR<=6 {printf "%-10s %5s %5s %s\n", $1, $3, $4, $11}'

# ---- network -------------------------------------------------------------
section "NETWORK"
line "IPv4:"      "$(hostname -I 2>/dev/null || echo unknown)"
line "Gateway:"   "$(ip r 2>/dev/null | awk '/default/ {print $3; exit}')"
line "DNS:"       "$(awk '/^nameserver/ {print $2; exit}' /etc/resolv.conf)"
line "Listeners:" "$(ss -tln 2>/dev/null | tail -n +2 | wc -l) TCP ports"
```

**What to notice:** `line()` for alignment, `/proc/loadavg` as a dependency-free source, `awk` for
extracting fields, and `|| fallback` for commands that may not exist.

---

## 2. `backup.sh` — safe, verified, dated backup

```bash
#!/usr/bin/env bash
#
# backup.sh — create and verify a compressed backup
# Usage: ./backup.sh <source-dir> [dest-dir]
#
set -euo pipefail

readonly NAME=$(basename "$0")
readonly STAMP=$(date +%Y%m%d-%H%M%S)
readonly KEEP=7                       # keep the last 7 archives

log()  { printf '[%s] %s\n' "$(date +%T)" "$*"; }
die()  { printf '[%s] ERROR: %s\n' "$(date +%T)" "$*" >&2; exit 1; }
usage(){ printf 'Usage: %s <source-dir> [dest-dir]\n' "$NAME" >&2; }

[[ $# -ge 1 ]] || { usage; exit 64; }

src="$1"
dest="${2:-$HOME/backups}"

[[ -d "$src" ]] || die "source is not a directory: $src"
command -v tar >/dev/null || die "tar is not installed"
mkdir -p "$dest" || die "cannot create $dest"

archive="$dest/$(basename "$src")-$STAMP.tar.gz"

log "backing up $src -> $archive"
tar -czf "$archive" -C "$(dirname "$src")" "$(basename "$src")"

log "verifying..."
tar -tzf "$archive" >/dev/null || die "archive verification FAILED: $archive"

log "ok: $(du -h "$archive" | cut -f1)"

# retention: delete all but the newest $KEEP archives
mapfile -t old < <(ls -1t "$dest"/"$(basename "$src")"-*.tar.gz 2>/dev/null | tail -n +$((KEEP + 1)))
if (( ${#old[@]} )); then
  log "removing ${#old[@]} old archive(s)"
  rm -f -- "${old[@]}"
fi

log "done"
```

**What to notice:** verify after writing (a backup you did not verify is not a backup), retention policy,
`-C` with `dirname`/`basename` so the archive contains relative paths, and distinct exit code `64` for
usage.

---

## 3. `logwatch.sh` — summarise a log file

```bash
#!/usr/bin/env bash
#
# logwatch.sh — count severity levels and show the busiest messages
# Usage: ./logwatch.sh [logfile]
#
set -euo pipefail

log="${1:-/var/log/syslog}"
[[ -r "$log" ]] || { echo "cannot read: $log" >&2; exit 66; }

count() {
  # grep exits 1 when nothing matches; that must not kill the script
  grep -ci -- "$1" "$log" || true
}

echo "File:       $log"
echo "Lines:      $(wc -l < "$log")"
echo
printf 'ERROR:      %s\n' "$(count error)"
printf 'WARNING:    %s\n' "$(count warning)"
printf 'INFO:       %s\n' "$(count info)"
echo
echo "Top 5 messages (timestamps stripped):"
sed -E 's/^\[?[0-9T :.-]+\]? *//' "$log" \
  | sort | uniq -c | sort -rn | head -5

echo
if (( $(count error) > 0 )); then
  exit 1        # signal "errors present" to whatever called us
fi
```

**What to notice:** `grep -c ... || true` (the `set -e` trap), `exit 1` as a *signal* not a crash, and
`sed -E` to strip timestamps before counting.

---

## 4. `make-users.sh` — onboarding from a CSV

```bash
#!/usr/bin/env bash
#
# make-users.sh — create users from a CSV: username,fullname,groups
# Usage: sudo ./make-users.sh users.csv
# Safety: prints a dry-run plan first unless CONFIRM=yes
#
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "run with sudo" >&2; exit 77; }
[[ $# -eq 1 ]] || { echo "Usage: $0 users.csv" >&2; exit 64; }

file="$1"
[[ -f "$file" ]] || { echo "no such file: $file" >&2; exit 66; }

created=0
skipped=0

while IFS=, read -r user fullname groups; do
  # skip the header and blank lines
  [[ "$user" == "username" || -z "$user" ]] && continue

  if id "$user" &>/dev/null; then
    echo "skip (exists): $user"
    skipped=$((skipped + 1))
    continue
  fi

  echo "create: $user ($fullname) groups=${groups:-none}"
  if [[ "${CONFIRM:-no}" == "yes" ]]; then
    useradd -m -c "$fullname" -s /bin/bash "$user"
    # set a random password and force a change at first login
    pass=$(tr -dc 'A-Za-z0-9!@#' </dev/urandom | head -c 16)
    echo "$user:$pass" | chpasswd
    chage -d 0 "$user"
    echo "  password: $pass"
    if [[ -n "$groups" ]]; then
      usermod -aG "$groups" "$user"
    fi
  fi
  created=$((created + 1))
done < "$file"

echo
echo "planned/created=$created skipped=$skipped"
[[ "${CONFIRM:-no}" == "yes" ]] || echo "DRY RUN — re-run with CONFIRM=yes to apply"
```

**What to notice:** idempotence (skip existing users), dry-run by default, root check, `IFS=,` for CSV,
`chage -d 0` to force a password change, and `&>/dev/null` for quiet existence checks.

---

## 5. `disk-alert.sh` — a cron-friendly monitor

```bash
#!/usr/bin/env bash
#
# disk-alert.sh — warn when any filesystem is over THRESHOLD percent
# Usage: ./disk-alert.sh [threshold]
# Cron:  */15 * * * * /home/student/bin/disk-alert.sh 85 >> /var/log/disk-alert.log 2>&1
#
set -euo pipefail

threshold="${1:-85}"
[[ "$threshold" =~ ^[0-9]+$ ]] || { echo "threshold must be a number" >&2; exit 64; }

alert=0

# skip the header, drop the % sign, compare numerically
df -P -x tmpfs -x devtmpfs | tail -n +2 | while read -r fs blocks used avail pcent mount; do
  pct="${pcent%\%}"
  if (( pct >= threshold )); then
    printf 'ALERT %s is %s%% full (%s free) on %s\n' "$mount" "$pct" "$avail" "$fs"
    alert=1
  fi
done

# NOTE: the variable above is set inside a pipeline (subshell) and is lost.
# For a real exit status, use process substitution:
alert=0
while read -r fs blocks used avail pcent mount; do
  pct="${pcent%\%}"
  (( pct >= threshold )) || continue
  printf 'ALERT %s is %s%% full (%s free) on %s\n' "$mount" "$pct" "$avail" "$fs"
  alert=1
done < <(df -P -x tmpfs -x devtmpfs | tail -n +2)

if (( alert )); then
  exit 1
fi
echo "all filesystems below ${threshold}%"
exit 0
```

**What to notice:** the deliberate bug at the top of the loop (the subshell problem from chapter 4) and the
correct version below it. This is the single most common pipeline bug in real scripts. Also: `df -P` for
portable output, `-x tmpfs` to skip fake filesystems, and exit `1` so cron/monitoring can react.

---

## How to learn from these

For each script, do all four:

1. **Run it.** Note the output.
2. **Break it on purpose.** Remove a quote, a `then`, a `fi`. Read the error. Fix it.
3. **Extend it.** Add one feature you actually want (e.g. `--help`, JSON output, email on alert).
4. **Explain it out loud.** If you cannot explain a line, that line is your homework.

---

## Your next step

Now do the exercises in `exercises/`:

| File | Builds on |
|---|---|
| `01-hello.sh` | chapter 01 |
| `02-greeting.sh` | chapter 02 |
| `03-file-check.sh` | chapter 03 |
| `04-count-lines.sh` | chapter 04 |
| `05-backup.sh` | chapters 05, 07 |
| `06-sysreport.sh` | everything |

Each starter has `TODO` comments. Fill them in, run, compare with `solutions/`.
