stdlib_import "array/join"

stdlib_array_serialize() {
  local var_arg
  if [[ "$1" == "-A" ]]; then
    var_arg="$2"
    shift 2
  fi

  if [[ "$var_arg" == "" ]]; then
    stdlib_argparser error/missing_arg "-A"
    return 1
  fi

  declare -n var_ref="${var_arg}"
  local -a lines=()

  local key line
  for key in "${!var_ref[@]}"; do
    printf -v line "%s=%s" "$key" "${var_ref[$key]}"
    lines+=("$line")
  done

  printf "%s\n" "${ stdlib_array_join --delim $'\n' -a lines; }"
}
