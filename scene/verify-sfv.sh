#!/bin/bash
# verify_sfv.sh - Recursively verify SFV files
# Default: check all files and continue
# Option: -f	stop on first failure
# Option: -d	specify release directory

set -euo pipefail

STOP_ON_FAIL=0
DIR="$PWD"

# Parse options -f and -d
TEMP=$(getopt -o fd: -l dir: -n "verify_sfv.sh" -- "$@")
eval set -- "$TEMP"

while true; do
    case "$1" in
        -f) STOP_ON_FAIL=1; shift ;;
		-d|--dir) DIR="$2"; shift 2 ;;
        --) shift; break ;;
        *) break ;;
    esac
done

# Normalize directory path
DIR="${DIR%/}"
if [ "$DIR" = "." ]; then
    DIR="$PWD"
fi

cd "$DIR"

# Main loop: use null-separated filenames to handle spaces
while IFS= read -r -d '' sfv; do
    echo "=== Checking $sfv ==="
    if [ $STOP_ON_FAIL -eq 1 ]; then
        rhash --check "$sfv" || exit 1
    else
        rhash --check "$sfv"
    fi
done < <(find . -type f -iname "*.sfv" -print0)