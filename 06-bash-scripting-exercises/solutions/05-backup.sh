#!/usr/bin/env bash
# SOLUTION 05 — backup.sh
# A backup script with verification, retention, and cleanup on failure.

set -euo pipefail

readonly NAME=$(basename "$0")
readonly STAMP=$(date +%F)
readonly KEEP=3

log()   { printf '[%s] %s\n' "$(date +%T)" "$*"; }
die()   { printf '[%s] ERROR: %s\n' "$(date +%T)" "$*" >&2; exit 1; }
usage() { printf 'Usage: %s <source-dir> [dest-dir]\n' "$NAME" >&2; }
need()  { command -v "$1" >/dev/null 2>&1 || die "missing dependency: $1"; }

[[ $# -ge 1 ]] || { usage; exit 64; }

src="$1"
dest="${2:-$HOME/backups}"

[[ -d "$src" ]] || die "source is not a directory: $src"
need tar
mkdir -p "$dest" || die "cannot create $dest"

archive="$dest/$(basename "$src")-$STAMP.tar.gz"

# --- cleanup partial archive on failure ----------------------------------
partial=0
cleanup() {
  if [[ $partial -eq 1 && -f $archive ]]; then
    rm -f -- "$archive"
    log "removed partial archive"
  fi
}
trap cleanup EXIT

# --- create ---------------------------------------------------------------
log "creating $archive"
partial=1
tar -czf "$archive" -C "$(dirname "$src")" "$(basename "$src")"
partial=0

# --- verify ---------------------------------------------------------------
log "verifying archive"
tar -tzf "$archive" >/dev/null || die "archive failed verification: $archive"
log "ok: $(du -h "$archive" | cut -f1)"

# --- retention ------------------------------------------------------------
mapfile -t old < <(ls -1t "$dest"/"$(basename "$src")"-*.tar.gz 2>/dev/null | tail -n +$((KEEP + 1)))
if (( ${#old[@]} )); then
  log "removing ${#old[@]} old archive(s)"
  rm -f -- "${old[@]}"
fi

log "done"
