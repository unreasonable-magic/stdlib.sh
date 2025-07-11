stdlib_array_join() {
  local delim=""
  if [[ "$1" == "--delim" ]]; then
    delim="$2"
    shift 2
  fi

  local IFS="$delim"
  printf "%s\n" "$*"
}
