# delegate_to_bash.zsh - Run bash functions and capture env var changes
#
# Usage: delegate_to_bash <script_path> <function_name> [env_vars...] [-- args...]
#
# Example:
#   delegate_to_bash "$HOME/bin/awsp" awsp AWS_PROFILE AWS_REGION
#   delegate_to_bash "$HOME/bin/awsp" awsp AWS_PROFILE -- --help

delegate_to_bash() {
    local script="$1"
    local func="$2"
    shift 2

    if [[ ! -f "$script" ]]; then
        echo "delegate_to_bash: script not found: $script" >&2
        return 1
    fi

    # Collect env vars to capture (before --) and args (after --)
    local -a env_vars=()
    local -a func_args=()
    local seen_separator=0

    for arg in "$@"; do
        if [[ "$arg" == "--" ]]; then
            seen_separator=1
        elif (( seen_separator )); then
            func_args+=("$arg")
        else
            env_vars+=("$arg")
        fi
    done

    # Default to common AWS vars if none specified
    if (( ${#env_vars[@]} == 0 )); then
        env_vars=(AWS_PROFILE AWS_REGION AWS_DEFAULT_REGION AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN)
    fi

    local env_file
    env_file=$(mktemp) || return 1

    # Build list of env vars as a string for bash
    local env_vars_str=""
    for v in "${env_vars[@]}"; do
        env_vars_str+="$v "
    done

    # Build args string, properly quoted
    local args_str=""
    for a in "${func_args[@]}"; do
        args_str+="$(printf '%q ' "$a")"
    done

    # Run bash with explicit TTY connection for interactive input/output
    # Use a heredoc to pass the script, which avoids quoting issues
    bash --norc --noprofile -c "
        source \"$script\"
        $func $args_str
        exit_code=\$?
        # Write env vars to file
        for var in $env_vars_str; do
            if [[ -n \"\${!var+set}\" ]]; then
                printf 'export %s=%q\n' \"\$var\" \"\${!var}\"
            fi
        done > \"$env_file\"
        exit \$exit_code
    " </dev/tty

    local bash_exit=$?

    # Source the env file to import changes into zsh
    if [[ -s "$env_file" ]]; then
        source "$env_file"
    fi

    rm -f "$env_file"
    return $bash_exit
}
