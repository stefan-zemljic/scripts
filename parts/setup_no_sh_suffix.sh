command_not_found_handle() {
    local cmd="$1"
    shift

    # Check if "$cmd.sh" exists somewhere in PATH and is executable
    local candidate
    candidate="$(command -v "$cmd.sh" 2>/dev/null)"
    if [ -n "$candidate" ]; then
        "$candidate" "$@"   # run it with args
        return $?
    fi

    echo "bash: $cmd: command not found" >&2
    return 127
}