stdlib_import "error"
stdlib_import "array/join"

stdlib_array_to_sentence() {
  local returnvar
  if [[ "$1" == "-v" ]]; then
    returnvar="$2"
    shift 2
  fi

  local input
  local -a items=()
  
  # Check if input should come from stdin (no args)
  if [[ $# -eq 0 ]]; then
    # Try to read from stdin
    if [[ ! -t 0 ]]; then
      while IFS= read -r line; do
        [[ -n "$line" ]] && items+=("$line")
      done
    fi
  else
    # Use arguments as input
    while [[ $# -gt 0 ]]; do
      items+=("$1")
      shift
    done
  fi

  # Check if we got any items
  if [[ ${#items[@]} -eq 0 ]]; then
    stdlib_error_warning "no items provided"
    return 1
  fi

  local result
  
  # Join with commas and "and" for the last item
  if [[ ${#items[@]} -eq 1 ]]; then
    result="${items[0]}"
  elif [[ ${#items[@]} -eq 2 ]]; then
    result="${items[0]} and ${items[1]}"
  else
    local last_index=$((${#items[@]} - 1))
    local -a first_items=("${items[@]:0:$((last_index))}")
    local comma_joined
    comma_joined=$(stdlib_array_join -d ", " -a first_items)
    result="$comma_joined and ${items[$last_index]}"
  fi

  if [[ -n "$returnvar" ]]; then
    declare -g "$returnvar"="$result"
  else
    printf "%s\n" "$result"
  fi

  return 0
}