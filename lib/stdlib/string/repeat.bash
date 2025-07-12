stdlib_string_repeat() {
  if [[ $# -lt 2 ]]; then
    stdlib_argparser error/length_mismatch 2
    return 1
  fi

  local string_arg="$1"
  local -i count_arg="$2"

  local repeated=""
  local -i iteration=0
  while [[ $iteration -lt $count_arg ]]; do
    repeated+="$string_arg"
    iteration+=1
  done

  printf "%s\n" "$repeated"
}
