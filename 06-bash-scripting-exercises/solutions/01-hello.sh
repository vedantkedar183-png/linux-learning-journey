#!/usr/bin/env bash
# SOLUTION 01 — hello.sh
# Compare only after writing your own version.

echo "Hello, Linux!"
echo "User:    $(whoami)"
echo "Where:   $(pwd)"
echo "Date:    $(date '+%A %d %B %Y')"
echo "Kernel:  $(uname -r)"
