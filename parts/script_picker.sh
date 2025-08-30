set -euo pipefail

# Ensure fzf is installed
if ! command -v fzf >/dev/null 2>&1; then
    echo "Error: fzf is not installed." >&2
    return 1
fi

# Build search paths: current, parent, then home/scripts
search_paths=(
    "$PWD/scripts" "$PWD"
    "$(dirname "$PWD")/scripts" "$(dirname "$PWD")"
    "$HOME/scripts"
)

# Collect .sh and executable files (no subfolders)
files=$(
    for dir in "${search_paths[@]}"; do
        if [ -d "$dir" ]; then
            find "$dir" -maxdepth 1 -type f \( -name "*.sh" -o -perm -u+x \)
        fi
    done | sort -u
)

if [ -z "$files" ]; then
    echo "No scripts or executables found in search paths." >&2
    return 1
fi

# Build mapping: display name → absolute path
choices=$(
    while IFS= read -r f; do
        abs=$(realpath "$f")

        if [[ $abs == "$HOME/scripts/"* || $abs == "$HOME/my_scripts/"* ]]; then
            rel="~${abs#$HOME}"
        else
            rel=$(realpath --relative-to="$PWD" "$abs")
        fi

        rel_display="${rel%.sh}"   # strip trailing .sh if present
        printf "%s\t%s\n" "$rel_display" "$abs"
    done <<< "$files"
)

# Let user pick (shows relative path without .sh)
selected=$(printf "%s\n" "$choices" \
    | cut -f1 \
    | fzf --no-mouse --layout=reverse --height=~40
) || return 1

if [ -z "$selected" ]; then
    echo "No script selected." >&2
    return 1
fi

# Lookup absolute path for chosen item
abs=$(printf "%s\n" "$choices" | awk -F'\t' -v rel="$selected" '$1 == rel {print $2; exit}')

# Prompt user for arguments
read -rp "Arguments for $selected: " user_args

# Run the script with provided arguments
cmd="\"$abs\" $user_args"
history -s "$cmd"
eval "$cmd"
