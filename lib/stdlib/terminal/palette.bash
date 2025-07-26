stdlib_import "argparser"
stdlib_import "terminal/reader"
stdlib_import "terminal/reader/readkey"
stdlib_import "array/join"
stdlib_import "param/join"
stdlib_import "trapstack"

enable kv

stdlib_terminal_palette_stack_push() {
  printf '\e[#P'
}

stdlib_terminal_palette_stack_pop() {
  printf '\e[#Q'
}

stdlib_terminal_palette_color_set() {
  # Turn the key=value params into an assoc array
  local -A args_kv
  kv -A args_kv -s "=" <<< "${ stdlib_param_join --delim $'\n' "$@"; }"

  local ansi key value
  for key in "${!args_kv[@]}"; do
    value="${args_kv["$key"]}"

    # If the value is blank or `-`, then read the value from STDIN instead
    if [[ "$value" == "" || "$value" == "-" ]]; then
      IFS=$'\n' read -r value
    fi

    # This approach will leave a trailing ';' at the end, but that doesn't seem
    # to matter in my testing
    ansi+="$key=$value;"
  done

  printf "\033]21;%s\007" "$ansi" > /dev/tty
}

stdlib_terminal_palette_color_reset() {
  # Passing no value to a color will reset it
  printf "\033]21;%s\007" "${ stdlib_param_join --delim ";" "$@"; }" > /dev/tty
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
