stdlib_array_join() {
  local IFS=$'\n'
  shift
  echo "$*"
}
