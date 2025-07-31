stdlib_import "argparser"
stdlib_import "terminal/reader"
stdlib_import "terminal/reader/readkey"
stdlib_import "array/join"
stdlib_import "param/join"
stdlib_import "trapstack"
stdlib_import "array/serialize"
stdlib_import "terminal/osc"

enable kv

# https://sw.kovidgoyal.net/kitty/color-stack/

# stdlib_terminal_palette_stack_push() {
#   printf '\e[#P'
#   # printf '\e]30001\e\\'
# }
# 
# stdlib_terminal_palette_stack_pop() {
#   printf '\e[#Q'
#   # printf '\e]30101\e\\'
# }

stdlib_terminal_palette_color_set() {
  local input="${| stdlib_argparser_parse -- "$@"; }"
  if [[ "$input" == "" ]]; then
    stdlib_argparser error/missing_arg "nothing to parse"
    return 1
  fi

  local -A args_kv
  kv -A args_kv -s "=" <<< "$input"

  local response key value
  for key in "${!args_kv[@]}"; do
    value="${args_kv["$key"]}"
    color="$value"

    case "$key" in
      background|foreground|cursor|selection_background|selection_foreground)
        response+="${ stdlib_terminal_osc "set_${key}" "$color"; }"
        ;;
      color*)
        response+="${ stdlib_terminal_osc "set_color" "${key/color/}" "$color"; }"
        ;;
      *)
        stdlib_argparser error/invalid_arg "$key"
        return 1
        ;;
    esac
  done

  printf "%b" "$response"
}

stdlib_terminal_palette_reset() {
  if [[ "$1" == "all" ]]; then
    local buffer=""

    buffer+="${ stdlib_terminal_osc "reset_foreground"; }"
    buffer+="${ stdlib_terminal_osc "reset_background"; }"
    buffer+="${ stdlib_terminal_osc "reset_cursor"; }"
    buffer+="${ stdlib_terminal_osc "reset_mouse_foreground"; }"
    buffer+="${ stdlib_terminal_osc "reset_mouse_background"; }"
    buffer+="${ stdlib_terminal_osc "reset_selection_foreground"; }"
    buffer+="${ stdlib_terminal_osc "reset_selection_background"; }"

    local -i idx=0
    while [[ "$idx" -le 255 ]]; do
      buffer+="${ stdlib_terminal_osc "reset_color" "$idx"; }"
      ((idx++))
    done

    printf "%b" "$buffer"
  fi
}

stdlib_terminal_palette_query() {
  local values_only_arg=false
  if [[ "$1" == "--values-only" ]]; then
    values_only_arg=true
    shift 1
  fi

  # Start capturing key presses into the terminal
  stdlib_terminal_reader_start

  local query=""
  if [[ $# -eq 0 ]]; then
    query="foreground=?;background=?;selection_background=?;selection_foreground=?;cursor=?;cursor_text=?"
  else
    local arg
    for arg in "$@"; do
      query+="${arg}=?;"
    done
  fi

  # Send the query to the terminal
  printf "\033]21;%s\007" "$query" > /dev/tty

  # Read what ever was "typed" into the terminal
  stdlib_terminal_reader_readkey

  # Grab the reply
  local response="$REPLY"
  unset REPLY

  # Remove the `21` from the start
  response="${response:3}"

  # Convert ; to new lines so we can easily parse as a kv
  response="${response//;/$'\n'}"

  # Turn into an assoc array
  local -A response_kv
  kv -A response_kv -s "=" <<< "$response"

  if [[ "$values_only_arg" == true ]]; then
    local -a values=("${response_kv[@]}")
    printf "%s\n" "${ stdlib_array_join -a values --delim $'\n'; }"
  else
    # Returns the array in a key=value pairs
    stdlib_array_serialize -A response_kv
  fi
}
