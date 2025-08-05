stdlib_string_unescape() {
  # Reading from stdin adds a new line at the end of input, so that's why we
  # have 2 different prints because we don't want to double up
  local input
  if [ $# -gt 0 ]; then
    input="$1"
    printf "%s\n" "${input@E}"
  else
    IFS= read -r -d '' input
    printf "%s" "${input@E}"
  fi
}
