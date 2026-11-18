#!/usr/bin/env bash
# EXERCISE 04 — count-lines.sh
# Chapter: 04-loops.md
#
# Goal: loop over files safely and produce a summary.
#
# Tasks:
#   1. Accept an optional directory argument (default: current directory).
#   2. Validate that the directory exists.
#   3. Loop over *.log files. Enable nullglob so an empty match is not a literal "*.log".
#   4. Skip empty files and count how many you skipped.
#   5. Print each filename and its line count, aligned with printf.
#   6. Print a total line count at the end.
#   7. Exit 0 even when there are no .log files (print a message instead).
#
# Run: ./04-count-lines.sh
#      ./04-count-lines.sh /var/log
#
# TODO: implement it below.

set -euo pipefail

# TODO: shopt -s nullglob
# TODO: dir="${1:-.}" and validation
# TODO: for loop with -s check and continue
# TODO: wc -l < "$f"  and running totals
# TODO: printf '%-40s %8d\n' ...
