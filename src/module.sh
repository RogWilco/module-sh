#!/usr/bin/env bash

module::route() {
  local module_name

  # Only show debug information if MODULE_DEBUG is set
  if [[ -n "${MODULE_DEBUG}" ]]; then
    echo "Call stack:"
    for ((i = 0; i < ${#FUNCNAME[@]}; i++)); do
        echo "  [$i] ${FUNCNAME[$i]} (called from ${BASH_SOURCE[$i+1]}:${BASH_LINENO[$i]})"
    done
    echo "Function called with arguments: $*"
  fi

  # If parent script is being sourced, do nothing
  if [[ "$(module::_check_execution_context)" == "sourced" ]]; then
    return
  fi

  # If parent script is being executed, perform routing:
  module_name=$(module::_get_module_name "$0")

  # if $1 is provided and  function <caller_file_without_extension>::$1() exists, run it and forward any arguments
  if [[ -n "$1" ]] && declare -F "$module_name::$1" > /dev/null; then
    func="$module_name::$1"
    shift
    "$func" "$@"
    return
  fi

  # otherwise if <caller_file_without_extension> exists, run it and forward any arguments
  if declare -F "$module_name" > /dev/null; then
    "$module_name" "$@"
    return
  fi

  # otherwise, neither function exists
  echo "Error: Function '$module_name' not found."
  exit 1
}

module::_init() {
  MODULE_ARGS=("$@")

  trap 'module::_trap' EXIT
}

module::_trap() {
  module::route "${MODULE_ARGS[@]}"
}

module::_get_module_name() {
  filename=$(basename "$1")
  echo "${filename%.*}"
}

module::_check_execution_context() {
    # If module.sh is run directly, treat it as executed
    if [[ "${#BASH_SOURCE[@]}" == 2 ]]; then  # Changed from 1 to 2 due to function
        echo "executed"
        exit 0
    fi

    # Check if the calling script is being executed or sourced
    # Using index 2 instead of 1 to skip the function's stack entry
    if [[ "${BASH_SOURCE[3]}" == "$0" ]]; then
        echo "executed"
    else
        echo "sourced"
    fi
}

module::_init "$@"
