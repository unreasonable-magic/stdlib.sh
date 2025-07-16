stdlib_import "error"

stdlib_trapstack_init() {
  if [[ -z $__stdlib_screen_cursor_state_init ]]; then
    trap 'stdlib_trapstack_broadcast EXIT $?' EXIT
    trap 'stdlib_trapstack_broadcast INT $?' INT
    trap 'stdlib_trapstack_broadcast TERM $?' TERM

    declare -gA __stdlib_trapstack_listeners=()
    declare -g __stdlib_trapstack_init="true"
  fi
}

stdlib_trapstack_add() {
  __stdlib_trapstack_listeners["$1"]="true"
}

stdlib_trapstack_remove() {
  unset "__stdlib_trapstack_listeners[$1]"
}

stdlib_trapstack_broadcast() {
  local signal="$1"
  local exit_code="$2"

  for function_name in "${!__stdlib_trapstack_listeners[@]}"; do
    # Sometimes parts of the array can become unset if they're removed at
    # runtime, so ignore any unset parts of the array
    if [[ -n "$function_name" ]]; then
      "${function_name}" "$signal" "$exit_code"
    fi
  done

  if [[ "$signal" == INT ]]; then
    exit
  fi
}
