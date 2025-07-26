stdlib_param_join() {
  if [[ "$1" == "--delim" ]]; then
    local IFS="$2"
    shift 2
  fi

  printf "%s\n" "$*"
}
