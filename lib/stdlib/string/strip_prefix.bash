stdlib_import "test"

stdlib_string_strip_prefix() {
  local input
  local prefix
  
  if [ $# -gt 0 ]; then
    input="$1"
    prefix="${2:-}"
  else
    input="$(cat)"
    prefix="${1:-}"
  fi

  if stdlib_test string/is_empty "$input"; then
    printf "\n"
    return
  fi

  # Remove prefix if it exists
  if [[ "$input" == "$prefix"* ]]; then
    input="${input#"$prefix"}"
  fi

  printf "%s\n" "$input"
}