_update_scripts_path() {
    local dirs=()

    dirs+=("$PWD/scripts" "$PWD/my_scripts" "$PWD")

    if [ -n "$PWD" ] && [ "$PWD" != "/" ]; then
        local parent="$(dirname "$PWD")"
        dirs+=("$parent/scripts" "$parent/my_scripts" "$parent")
    fi

    dirs+=("$HOME/scripts" "$HOME/my_scripts")

    local valid=()
    for d in "${dirs[@]}"; do
        [ -d "$d" ] && valid+=("$d")
    done

    export PATH="$(IFS=:; echo "${valid[*]}"):$ORIGINAL_PATH"
}

if [ -z "$ORIGINAL_PATH" ]; then
    export ORIGINAL_PATH="$PATH"
fi

PROMPT_COMMAND="_update_scripts_path${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
