#!/usr/bin/env bash
# SOLUTION 06 — sysreport.sh

set -euo pipefail

readonly NAME=$(basename "$0")
out="${1:-}"

if [[ -n "$out" ]]; then
  exec > >(tee -a "$out") 2>&1
fi

line()    { printf '%-14s %s\n' "$1" "$2"; }
section() { printf '\n== %s ==\n' "$1"; }

section "SYSTEM"
line "Host:"     "$(hostname)"
line "Kernel:"   "$(uname -r)"
line "Uptime:"   "$(uptime -p 2>/dev/null || uptime)"
line "User:"     "$(whoami)"
line "Cores:"    "$(nproc)"
line "Load:"     "$(cut -d' ' -f1-3 /proc/loadavg)"

section "MEMORY"
line "Memory:"   "$(free -h | awk '/^Mem:/ {print $3" used / "$2" total"}')"
line "Swap:"     "$(free -h | awk '/^Swap:/ {print $3" used / "$2" total"}')"

section "DISK"
while read -r fs size used avail pcent mount; do
  printf '%-24s %6s used of %-6s (%s) %s\n' "$fs" "$used" "$size" "$pcent" "$mount"
done < <(df -P -x tmpfs -x devtmpfs | tail -n +2)

section "TOP 3 BY MEMORY"
ps aux --sort=-%mem | awk 'NR>1 && NR<=4 {printf "%-10s %5s%%  %s\n", $1, $4, $11}'

section "NETWORK"
line "IPv4:"     "$(hostname -I 2>/dev/null || echo unknown)"
line "Gateway:"  "$(ip r 2>/dev/null | awk '/default/ {print $3; exit}')"
line "DNS:"      "$(awk '/^nameserver/ {print $2; exit}' /etc/resolv.conf)"

exit 0
