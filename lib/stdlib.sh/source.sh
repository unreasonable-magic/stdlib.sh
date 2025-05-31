declare -g -a stdlib_source_stack=()

stdlib::source () {
  # printf "%-${#stdlib_source_stack[@]}s" ""
  # printf "%s\n" $1

  stdlib_source_stack+=("$1")
  source "$@"
  local -i returned_exit_status="$?"

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
