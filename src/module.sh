#!/usr/bin/env    bash

#?/name           module - a simple bash module system
#?/synopsis       source module

#?/environment    MODULE_DEBUG if set, debug information will be printed to the console
#?/environment    MODULE_ARGS contains the arguments passed to the module

set -euo pipefail

#@/main
 # Initializes the module system
 #
 # @arg $@ arguments to be forwarded to the module
 #
module() {
  MODULE_ARGS=("$@")

  trap 'module::_route' EXIT
}

#@/private
# Applies rouing logic to <caller> (the sourcing script).
#
# @arg $@ arguments to be forwarded to the module
#
# @stdout debug information if MODULE_DEBUG is set
# @stderr error message if the routing failed
#
# @exit 0 if the routing succeeded
# @exit 1 if the routing failed
#
module::_route() {
  local module_name

  module::_debug "Function called with arguments: ${MODULE_ARGS[*]}"

  if [[ "${MODULE_DEBUG:-0}" -eq 0 ]]; then
    local call_stack="Call stack:"
    for ((i = 0; i < ${#FUNCNAME[@]}; i++)); do
        if [[ -n ${BASH_SOURCE[$i+1]:-} ]]; then
            call_stack+="\n  [$i] ${FUNCNAME[$i]} (called from ${BASH_SOURCE[$i+1]}:${BASH_LINENO[$i]})"
        else
            call_stack+="\n  [$i] ${FUNCNAME[$i]} (called from unknown location)"
        fi
    done

    module::_debug "$call_stack"
  fi

  # <caller> is being sourced, skip routing
  if [[ "$(module::_check_context)" == "sourced" ]]; then
    return
  fi

  # <caller> is being executed, apply routing
  module_name=$(module::_get_module_name "$0")

  # Route: <caller>::$1()
  if [[ -n "${1:-}" ]] && declare -F "$module_name::$1" > /dev/null; then
    func="$module_name::$1"
    shift
    "$func" "${MODULE_ARGS[@]}"
    return
  fi

  # Route: <caller>()
  if declare -F "$module_name" > /dev/null; then
    "$module_name" "${MODULE_ARGS[@]}"
    return
  fi

  # Routing failed, exit with error
  echo "Error: Function '$module_name' not found."
  exit 1
}

#@/private checks the execution context of the <caller> script
module::_check_context() {
    # If module.sh is run directly, treat it as executed
    if [[ "${#BASH_SOURCE[@]}" == 2 ]]; then
        echo "executed"
        exit 0
    fi

    # Check if the calling script is being executed or sourced
    if [[ "${BASH_SOURCE[3]:-}" == "$0" ]]; then
        echo "executed"
    else
        echo "sourced"
    fi
}

#@/private prints debug information if MODULE_DEBUG is set
module::_debug() {
  [[ "${MODULE_DEBUG:-0}" -eq 0 ]] && return
  echo "$*"
}

#@/private extracts the module name from the <caller> script
module::_get_module_name() {
  filename=$(basename "$1")
  echo "${filename%.*}"
}

module "$@"
