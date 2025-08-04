stdlib_import "test"

stdlib_string_trim() {
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

  input="${input#"${input%%[![:space:]]*}"}"
  input="${input%"${input##*[![:space:]]}"}"

  printf "%s\n" "$input"
}
