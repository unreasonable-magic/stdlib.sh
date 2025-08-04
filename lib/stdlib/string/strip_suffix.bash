stdlib_import "test"

stdlib_string_strip_suffix() {
  local input
  local suffix
  
  if [ $# -gt 0 ]; then
    input="$1"
    suffix="${2:-}"
  else
    input="$(cat)"
    suffix="${1:-}"
  fi

  if stdlib_test string/is_empty "$input"; then
    printf "\n"
    return
  fi

  # Use parameter expansion which handles newlines properly
  # Check if the string ends with the suffix
  local input_length=${#input}
  local suffix_length=${#suffix}
  local suffix_start=$((input_length - suffix_length))
  
  if [[ $suffix_start -ge 0 ]] && [[ "${input:$suffix_start:$suffix_length}" == "$suffix" ]]; then
    input="${input:0:$suffix_start}"
  fi

  printf "%s\n" "$input"
}