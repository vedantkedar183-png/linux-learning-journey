# Project 02 — Backup Tool

**Difficulty:** ⭐⭐ · **Time:** 1.5 h
**Skills:** `tar`, `trap`, verification, retention, `flock`, exit codes

---

## Goal

Build `backup.sh`: a backup you would trust with real data. It creates a dated archive, **verifies** it,
rotates old copies, refuses to run twice at once, and cleans up after itself if it fails.

A backup you have not verified is not a backup. This project is mostly about that sentence.

---

## Requirements

1. Usage: `./backup.sh <source-dir> [dest-dir]` (dest defaults to `~/backups`).
2. Exit codes: `64` bad usage, `66` missing source, `73` cannot create destination, `1` other failures.
3. Check dependencies (`tar`) **before** doing any work.
4. Archive name: `<basename>-<YYYY-MM-DD>.tar.gz`.
5. Use `tar -C "$(dirname "$src")" "$(basename "$src")"` so the archive has relative paths.
6. **Verify** with `tar -tzf`; fail loudly if verification fails.
7. Delete the partial archive on any failure (`trap ... EXIT` + a `partial` flag).
8. Keep only the newest **3** archives; log which ones you delete.
9. Use `flock` so two copies cannot run at once.
10. Log every step with a timestamp; write to stderr for errors.
11. Print the final archive size.

---

## Step by step

### Step 1 — Setup
```bash
mkdir -p ~/linux-lab/projects/02-backup-tool
cd ~/linux-lab/projects/02-backup-tool
mkdir -p ~/{backups,data}
echo "important" > ~/data/file1.txt
dd if=/dev/urandom of=~/data/blob.bin bs=1M count=5 status=none
```

### Step 2 — Start with validation only
```bash
#!/usr/bin/env bash
set -euo pipefail

usage(){ printf 'Usage: %s <source-dir> [dest-dir]\n' "$(basename "$0")" >&2; }
die(){ printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[[ $# -ge 1 ]] || { usage; exit 64; }
src="$1"; dest="${2:-$HOME/backups}"
[[ -d "$src" ]] || { echo "not a directory: $src" >&2; exit 66; }
mkdir -p "$dest" || { echo "cannot create $dest" >&2; exit 73; }
echo "ok: $src -> $dest"
```
Test all three failure paths before adding anything else.

### Step 3 — Add the archive + verification
```bash
archive="$dest/$(basename "$src")-$(date +%F).tar.gz"
tar -czf "$archive" -C "$(dirname "$src")" "$(basename "$src")"
tar -tzf "$archive" >/dev/null || die "archive failed verification"
```

### Step 4 — Add cleanup-on-failure
```bash
partial=0
cleanup(){ [[ $partial -eq 1 && -f $archive ]] && rm -f -- "$archive"; }
trap cleanup EXIT
partial=1
tar -czf ...
partial=0
```
Prove it: make `tar` fail (e.g. `chmod 000` a file in the source, on a test copy) and confirm no
half-written archive is left behind.

### Step 5 — Add retention
```bash
mapfile -t old < <(ls -1t "$dest"/"$(basename "$src")"-*.tar.gz | tail -n +4)
(( ${#old[@]} )) && rm -f -- "${old[@]}"
```

### Step 6 — Add the lock
```bash
exec 9>"$dest/.backup.lock"
flock -n 9 || { echo "another backup is running" >&2; exit 0; }
```
Test: run `./backup.sh ~/data & ./backup.sh ~/data` — one should refuse politely.

### Step 7 — Write `test.sh`
A script that proves all seven behaviours (see "Proof it works").

---

## Proof it works

`test.sh` should check:

```bash
# 1. Archive is created
./backup.sh ~/data /tmp/bk && ls /tmp/bk/*.tar.gz

# 2. Archive is valid and contains the expected files
tar -tzf /tmp/bk/*.tar.gz | head

# 3. Contents match the source
mkdir -p /tmp/restore && tar -xzf /tmp/bk/*.tar.gz -C /tmp/restore
diff -r ~/data /tmp/restore/data

# 4. Missing source -> exit 66
./backup.sh /nope; echo $?

# 5. Bad usage -> exit 64
./backup.sh; echo $?

# 6. Retention keeps only 3
for i in 1 2 3 4 5; do ./backup.sh ~/data /tmp/bk >/dev/null; sleep 1; done
ls /tmp/bk/*.tar.gz | wc -l      # 3 (same-day archives overwrite; test with different dates or change the name scheme)

# 7. No partial file on failure
```

**Important detail:** because the name contains only the date, running twice on the same day **overwrites**.
Decide which behaviour you want:
- keep per-day snapshots → add `-H%M%S` to the name (then retention counts many files), or
- keep one per day → current scheme, and note it in your README.

Write down your choice. That is a design decision, and being able to explain it is the point.

---

## Stretch goals

1. Support `-e PATTERN` to exclude files (pass `--exclude=` to tar).
2. Support a remote destination over `rsync`/`ssh`.
3. Send a summary to `logger -t backup` so it appears in `journalctl`.
4. Add `--dry-run`.
5. Add an md5/sha256 manifest inside the archive and verify it on restore.

---

## Grading rubric

| Criterion | Points |
|---|---|
| Creates a valid, verifiable archive | 20 |
| Verification actually runs and fails loudly when broken | 20 |
| Distinct exit codes and clear messages | 15 |
| Cleanup of partial archives (proven) | 15 |
| Retention works and is logged | 10 |
| Lock prevents concurrent runs | 10 |
| `README.md` + `test.sh` present and honest | 10 |

**80+** = done. You now have a reusable tool for the rest of the course.
