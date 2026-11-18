#!/usr/bin/env bash
# EXERCISE 02 — greeting.sh
# Chapter: 02-variables-and-input.md
#
# Goal: take input from the user and from arguments.
#
# Tasks:
#   1. If $1 is provided, use it as the name. Otherwise ask with read -rp.
#   2. If the name ends up empty, use "anonymous" (use ${name:-anonymous}).
#   3. Ask for a favourite distro.
#   4. Print: Hello <name>, your favourite distro is <distro>.
#   5. Print how many arguments the script received.
#   6. Use set -euo pipefail.
#   7. Quote every variable.
#
# Run: ./02-greeting.sh
#      ./02-greeting.sh Alice
#
# TODO: implement it below.

set -euo pipefail

# TODO: get the name (argument or prompt)
# TODO: fallback to anonymous
# TODO: prompt for distro
# TODO: print the greeting and $#
