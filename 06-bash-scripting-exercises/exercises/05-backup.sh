#!/usr/bin/env bash
# EXERCISE 05 — backup.sh
# Chapter: 05-functions-and-arrays.md + 07-error-handling.md
#
# Goal: a backup script you would actually trust.
#
# Tasks:
#   1. Usage: ./05-backup.sh <source-dir> [dest-dir]
#   2. Exit 64 on bad usage; exit 66 if the source is missing.
#   3. Create functions: log(), die(), usage(), need().
#   4. need tar  (fail BEFORE doing any work).
#   5. Create "$dest/$(basename "$src")-$(date +%F).tar.gz" with tar -czf -C ...
#   6. Verify the archive with tar -tzf and die if it fails.
#   7. Print the final size with du -h.
#   8. Use a trap to delete the partial archive if the script exits with an error.
#   9. Keep only the newest 3 archives.
#
# Run: ./05-backup.sh ~/linux-lab
#      ./05-backup.sh /does/not/exist ; echo $?
#
# TODO: implement it below.

set -euo pipefail

# TODO: log() / die() / usage() / need()
# TODO: argument validation
# TODO: tar -czf with -C "$(dirname "$src")"
# TODO: tar -tzf verification
# TODO: trap + partial cleanup
# TODO: retention with ls -1t | tail -n +4
