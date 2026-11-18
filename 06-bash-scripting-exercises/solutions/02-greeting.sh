#!/usr/bin/env bash
# SOLUTION 02 — greeting.sh

set -euo pipefail

name="${1:-}"
if [[ -z "$name" ]]; then
  read -rp "What is your name? " name
fi
name="${name:-anonymous}"

read -rp "Favourite distro? " distro

echo "Hello $name, your favourite distro is $distro."
echo "Arguments received: $#"
