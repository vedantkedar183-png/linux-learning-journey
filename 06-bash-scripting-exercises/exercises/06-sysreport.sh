#!/usr/bin/env bash
# EXERCISE 06 — sysreport.sh
# Chapter: all of them
#
# Goal: a self-contained system report, like 08-common-scripts.md script #1,
# written by you from scratch.
#
# Requirements:
#   1. set -euo pipefail at the top.
#   2. A line() helper that aligns labels: printf '%-14s %s\n'.
#   3. A section() helper that prints a blank line then "== NAME ==".
#   4. Report: hostname, kernel, uptime, user, CPU cores, load average.
#   5. Report: memory used / total (from free -h with awk).
#   6. Report: each filesystem's use% (loop over df -P, skip tmpfs).
#   7. Report: the 3 processes using the most memory (ps aux + awk).
#   8. Report: IPv4 address, gateway, DNS server.
#   9. Accept one optional argument: an output file. If given, write the
#      report there AND show it (hint: exec > >(tee -a "$out") 2>&1).
#  10. Exit 0 on success.
#
# Run: ./06-sysreport.sh
#      ./06-sysreport.sh report.txt
#
# TODO: implement it below.

set -euo pipefail

# TODO: outline the sections, then fill one at a time and RUN after each.
