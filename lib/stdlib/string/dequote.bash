stdlib_string_dequote() {
  local input="$1"

  # Nothing to do if there's no string
  if [[ -z "$input" ]]; then
    printf "%s\n" "$input"
    return
  fi

  local dequoted="$input"

  # Get first and last characters
  local first_char="${input:0:1}"
  local last_char="${input: -1}"

  if [[ "$first_char" == '"' && "$last_char" == '"' && ${#input} -ge 2 ]]; then
    dequoted="${input:1:-1}"
    dequoted="${dequoted//\\\"/\"}"
  elif [[ "$first_char" == "'" && "$last_char" == "'" && ${#input} -ge 2 ]]; then
    dequoted="${input:1:-1}"
    dequoted="${dequoted//\\\'/\'}"
  fi

  printf "%s\n" "$dequoted"
}
