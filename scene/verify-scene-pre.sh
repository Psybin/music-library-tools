#!/usr/bin/env bash

# Default directory
DIR="."
VERBOSE=0

# --- getopt parsing ---
OPTS=$(getopt -o d:v --long dir:,verbose -n 'checkcrc' -- "$@")
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi
eval set -- "$OPTS"

while true; do
    case "$1" in
        -d|--dir ) DIR="$2"; shift 2 ;;
        -v|--verbose ) VERBOSE=1; shift ;;
        -- ) shift; break ;;
        * ) break ;;
    esac
done

# Normalize directory
DIR="${DIR%/}"      # Remove trailing slash
if [ "$DIR" = "." ]; then
    BASENAME=$(basename "$PWD")  # Use current working directory name
else
    BASENAME=$(basename "$DIR")
fi

echo "Checking release: $BASENAME"

# --- Fetch JSON from SRRDB API ---
URL="https://api.srrdb.com/v1/details/${BASENAME}"
JSON=$(curl -s "$URL")

if [ -z "$JSON" ]; then
    echo "Failed to fetch $URL"
    exit 1
fi

# Validate JSON
if ! echo "$JSON" | jq empty >/dev/null 2>&1; then
    echo "Invalid JSON received from $URL"
    exit 1
fi

# --- Determine JSON type and extract .files ---
JSON_TYPE=$(echo "$JSON" | jq -r 'type')

if [ "$JSON_TYPE" = "object" ]; then
    FILES_JSON=$(echo "$JSON" | jq '.files')
elif [ "$JSON_TYPE" = "array" ]; then
    LENGTH=$(echo "$JSON" | jq 'length')
    if [ "$LENGTH" -eq 0 ]; then
        echo "No files found in SRRDB for release $BASENAME"
        exit 0
    fi
    # Merge .files from all objects in array
    FILES_JSON=$(echo "$JSON" | jq '[.[] | select(has("files")) | .files] | add')
    if [ "$FILES_JSON" = "null" ]; then
        echo "No files found in SRRDB array objects"
        exit 0
    fi
else
    echo "Unexpected JSON structure: $JSON_TYPE"
    exit 1
fi

# Ensure FILES_JSON is not empty
FILE_COUNT=$(echo "$FILES_JSON" | jq 'length')
if [ "$FILE_COUNT" -eq 0 ]; then
    echo "No files found in SRRDB release $BASENAME"
    exit 0
fi

# --- Loop over local files ---
OK=0
FAIL=0
MISS=0

for FILE in "$DIR"/*; do
    [ -f "$FILE" ] || continue

    # Normalize local filename
    FILENAME=$(basename "$FILE")
    FILENAME_CLEAN=$(echo "$FILENAME" | tr -d '\r\n')

    # Compute CRC32, uppercase
    CRC=$(crc32 "$FILE" 2>/dev/null | tr '[:lower:]' '[:upper:]' | tr -cd 'A-F0-9')
    if [ -z "$CRC" ]; then
        echo "Failed to compute CRC for $FILE"
        continue
    fi

    # Lookup CRC in JSON (case-insensitive filename match)
    REMOTE_CRC=$(echo "$FILES_JSON" | jq -r --arg fn "$FILENAME_CLEAN" '
        .[] | select((.name | ascii_downcase) == ($fn | ascii_downcase)) | .crc
    ')

    REMOTE_CRC=$(echo "$REMOTE_CRC" | tr '[:lower:]' '[:upper:]' | tr -cd 'A-F0-9')

    if [ -z "$REMOTE_CRC" ] || [ "$REMOTE_CRC" = "null" ]; then
        echo "[MISS] $FILENAME not found in SRRDB listing"
        ((MISS++))
        continue
    fi

    if [ "$CRC" = "$REMOTE_CRC" ]; then
        echo "[OK]   $FILENAME ($CRC)"
        ((OK++))
    else
        echo "[FAIL] $FILENAME"
        echo "  Local : $CRC"
        echo "  Remote: $REMOTE_CRC"
        ((FAIL++))
    fi
done

# --- Summary ---
echo
echo "Summary for release $BASENAME:"
echo "  OK   : $OK"
echo "  FAIL : $FAIL"
echo "  MISS : $MISS"
