stdlib_import "test"

declare -a stdlib_source_stack=()

stdlib_source() {
  # printf "%-${#stdlib_source_stack[@]}s" ""
  # printf "%s\n" $1
  #
  local path="$1"
  shift

  local -i returned_exit_status

  stdlib_source_stack+=("$path")
  if stdlib_test file/is_regular "$path"; then
    source "$path" "$@"
    returned_exit_status="$?"
  else
    # Try and debug as to why the path couldn't be sourced
    if stdlib_test file/is_dir "$path"; then
      stdlib_error_log "$path can't be sourced as it's a directory"
    elif stdlib_test file/is_missing "$path"; then
      stdlib_error_log "$path doesn't exist"
    else
      stdlib_error_log "$path isn't a regular file"
    fi
    stdlib_error_stacktrace
    returned_exit_status=1
  fi

  # Recreate array and remove last element
  new_stdlib_source_stack=()
  local -i idx=1
  local -i length="${#stdlib_source_stack[@]}"
  for path in "${stdlib_source_stack[@]}"; do
    if [ $idx -eq $length ]; then
      break
    fi
    new_stdlib_source_stack+=("$path")
    idx+=1
  done
  stdlib_source_stack=("${new_stdlib_source_stack[@]}")

  return "$returned_exit_status"
}
