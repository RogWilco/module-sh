#!/usr/bin/env bash


# Synopsis:
# test [description] --command <command> [--expect-exit <exit_status>] [--expect-stderr <stderr>] [--expect-stdout <stdout>]
#
# Special values for --expect-stdout and --expect-stderr:
#   "*"     Match any output (including empty)
#   ""      Match no output (empty string)
#   <text>  Match exact text


# Positional Arguments:
# $1		description			default '<command>'


# Named Arguments:
# -c | --command				required
# -x | --expect-exit			default 0
# -e | --expect-stderr			default ''
# -o | --expect-stdout			default '*'


test() {
    local description command expect_exit=0 expect_stderr="" expect_stdout="*"

    # If first argument doesn't start with -, it's the description
    if [[ "${1:-}" != -* ]]; then
        description="$1"
        shift
    fi

    # Parse named arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--command)
                command="$2"
                shift 2
                ;;
            -x|--expect-exit)
                expect_exit="$2"
                shift 2
                ;;
            -e|--expect-stderr)
                expect_stderr="$2"
                shift 2
                ;;
            -o|--expect-stdout)
                expect_stdout="$2"
                shift 2
                ;;
            *)
                echo -e "\t\033[0;31m\u2717\033[0m Unknown argument: $1" >&2
                return 1
                ;;
        esac
    done

    # Command is required
    if [[ -z "${command:-}" ]]; then
        echo -e "\t\033[0;31m\u2717\033[0m Error: --command is required" >&2
        return 1
    fi

    # Use command as description if none provided
    description="${description:-$command}"

    # Run the command and capture output
    local stdout stderr exit_status
    { stdout=$(eval "$command" 2>/dev/null); } >/dev/null
    exit_status=$?
    stderr=$(eval "$command" 2>&1 >/dev/null)

    # Trim whitespace from outputs
    stdout=$(echo "$stdout" | xargs)
    stderr=$(echo "$stderr" | xargs)
    expect_stdout=$(echo "$expect_stdout" | xargs)
    expect_stderr=$(echo "$expect_stderr" | xargs)

    # Check exit status
    if [[ "$exit_status" != "$expect_exit" ]]; then
        echo -e "\t\033[0;31m\u2717\033[0m $description"
        echo -e "\t  \033[0;90mexpected exit: $expect_exit\033[0m"
        echo -e "\t  \033[0;90m  actual exit: $exit_status\033[0m"
        return 1
    fi

    # Check stdout
    if [[ "$expect_stdout" != "*" ]]; then
        if [[ "$stdout" != "$expect_stdout" ]]; then
            echo -e "\t\033[0;31m\u2717\033[0m $description"
            if [[ -z "$expect_stdout" ]]; then
                echo -e "\t  \033[0;90mexpected stdout: (no output)\033[0m"
            else
                echo -e "\t  \033[0;90mexpected stdout: $expect_stdout\033[0m"
            fi
            if [[ -z "$stdout" ]]; then
                echo -e "\t  \033[0;90m  actual stdout: (no output)\033[0m"
            else
                echo -e "\t  \033[0;90m  actual stdout: $stdout\033[0m"
            fi
            return 1
        fi
    fi

    # Check stderr
    if [[ "$expect_stderr" != "*" ]]; then
        if [[ "$stderr" != "$expect_stderr" ]]; then
            echo -e "\t\033[0;31m\u2717\033[0m $description"
            if [[ -z "$expect_stderr" ]]; then
                echo -e "\t  \033[0;90mexpected stderr: (no output)\033[0m"
            else
                echo -e "\t  \033[0;90mexpected stderr: $expect_stderr\033[0m"
            fi
            if [[ -z "$stderr" ]]; then
                echo -e "\t  \033[0;90m  actual stderr: (no output)\033[0m"
            else
                echo -e "\t  \033[0;90m  actual stderr: $stderr\033[0m"
            fi
            return 1
        fi
    fi

    # Test passed
    echo -e "\t\033[0;32m\u2713\033[0m $description"
    return 0
}

test::suite() {
	echo -e "\n\t\033[1m$1\033[0m"
}
