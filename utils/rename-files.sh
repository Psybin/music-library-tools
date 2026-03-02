#!/bin/bash
# Rename Files
# Renames files based on input

usage() {
    echo "Usage: $0 [-r] [-d] STRING [PATH]"
    echo "  -r      Recursive (include subdirectories)"
    echo "  -d      Also rename directories"
    echo "  STRING  The string to remove from names"
    echo "  PATH    Optional directory path (default: current directory)"
    exit 1
}

recursive=false
rename_dirs=false
while getopts "rd" opt; do
    case "$opt" in
        r) recursive=true ;;
        d) rename_dirs=true ;;
        *) usage ;;
    esac
done
shift $((OPTIND - 1))

string_to_remove="$1"
target_dir="${2:-.}"

if [ -z "$string_to_remove" ]; then
    usage
fi

if [ ! -d "$target_dir" ]; then
    echo "Error: '$target_dir' is not a directory."
    exit 1
fi

echo "Searching for names containing '$string_to_remove' in $target_dir..."
echo "----------------------------------------"

# Build find options
depth_opt=()
if ! $recursive; then
    depth_opt=(-maxdepth 1)
fi

type_opts=(-type f)
if $rename_dirs; then
    type_opts=(-type f -o -type d)
fi

mapfile -t matches < <(find "$target_dir" "${depth_opt[@]}" \( "${type_opts[@]}" \) -name "*$string_to_remove*")

if [ ${#matches[@]} -eq 0 ]; then
    echo "No matching files or directories found."
    exit 0
fi

# Function to highlight the string_to_remove in the path
highlight() {
    local input="$1"
    local search="$2"
    local RED=$'\033[0;31m'
    local NC=$'\033[0m'
    # Escape special regex chars in search string for sed
    local escaped_search
    escaped_search=$(printf '%s\n' "$search" | sed -e 's/[]\/$*.^|[]/\\&/g')
    # Use sed to replace with actual escape codes
    printf '%s\n' "$input" | sed "s/$escaped_search/${RED}&${NC}/g"
}

# Show matches with highlight
for path in "${matches[@]}"; do
    echo "$(highlight "$path" "$string_to_remove")"
done

echo "----------------------------------------"
echo
read -rp "Proceed to rename and remove '$string_to_remove' from these names? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

# Rename items
# Sort by depth (deepest first) so dirs are renamed after their contents
printf '%s\n' "${matches[@]}" | awk '{print length, $0}' | sort -nr | cut -d" " -f2- | while read -r path; do
    new_name="${path//$string_to_remove/}"
    if [ "$path" != "$new_name" ]; then
        mv "$path" "$new_name"
    fi
done

echo "Done."
