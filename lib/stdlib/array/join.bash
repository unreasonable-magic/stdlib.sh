stdlib_import "argparser"

stdlib_array_join() {
  local delim=""
  local -n array_ref

  while [[ $# -gt 0 ]]; do
    case $1 in
    --delim | -d)
      delim="$2"
      shift 2
      ;;
    -a)
      array_ref="$2"
      shift 2
      ;;
    *)
      stdlib_argparser error/invalid_arg "$1"
      return 1
      ;;
    esac
  done

  if [[ -z "${array_ref+x}" ]]; then
    stdlib_argparser error/missing_arg "array reference not provided or missing"
    return 1
  fi

  if [[ ${#array_ref[@]} -eq 0 ]]; then
    printf "\n"
    return 0
  fi

  local i
  local result="${array_ref[0]}"
  for ((i = 1; i < ${#array_ref[@]}; i++)); do
    result+="$delim${array_ref[i]}"
  done

  printf "%s\n" "$result"
}
