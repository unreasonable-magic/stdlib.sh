stdlib_function_name() {
  local quiet_arg
  if [[ "$1" == "--quiet" ]]; then
    quiet_arg=true
    shift
  fi

  if [[ "$1" =~ ^([a-zA-Z0-9_]+)$ ]]; then
    if [[ "$quiet_arg" == "" ]]; then
      printf "%s\n" "$1"
    fi
    return 0
  else
    return 1
  fi
}
