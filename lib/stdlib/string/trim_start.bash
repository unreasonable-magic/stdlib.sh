stdlib_string_trim_start() {
  local input
  if [ $# -gt 0 ]; then
    input="$1"
  else
    input="$(cat)"
  fi

  printf "%s\n" "${input#"${input%%[![:space:]]*}"}"
}
