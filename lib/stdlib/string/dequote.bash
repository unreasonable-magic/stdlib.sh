stdlib_import "test"

stdlib_string_dequote() {
  local input
  if [ $# -gt 0 ]; then
    input="$1"
  else
    input="$(cat)"
  fi

  if stdlib_test string/is_empty "$input"; then
    printf "\n"
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
    dequoted="${dequoted//"'\''"/"'"}"
  fi

  printf "%s\n" "$dequoted"
}
