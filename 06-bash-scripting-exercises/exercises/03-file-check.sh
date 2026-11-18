#!/usr/bin/env bash
# EXERCISE 03 — file-check.sh
# Chapter: 03-conditionals.md
#
# Goal: inspect a path and report what it is, safely.
#
# Tasks:
#   1. Require exactly one argument; print usage to stderr and exit 1 otherwise.
#   2. If the path does not exist, print an error and exit 2.
#   3. If it is a symlink, say where it points (readlink).
#   4. If it is a directory, print how many entries it contains.
#   5. If it is a regular file, print its size in bytes and r/w/x status.
#   6. Otherwise say it is a special file.
#   7. Use set -euo pipefail and quote everything.
#
# Run: ./03-file-check.sh /etc
#      ./03-file-check.sh /etc/hosts
#      ./03-file-check.sh /nope
#
# TODO: implement it below.

set -euo pipefail

# TODO: argument check (-lt 1)
# TODO: existence check (-e)
# TODO: symlink check (-L) + readlink
# TODO: directory/file branches (-d / -f)
# TODO: size with stat -c %s
