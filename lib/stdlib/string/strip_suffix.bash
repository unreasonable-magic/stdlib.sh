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

  # Remove suffix if it exists
  if [[ "$input" == *"$suffix" ]]; then
    input="${input%"$suffix"}"
  fi

  printf "%s\n" "$input"
}