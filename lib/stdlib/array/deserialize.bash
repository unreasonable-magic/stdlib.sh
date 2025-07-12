enable kv

stdlib_array_deserialize() {
  local var_arg
  if [[ "$1" == "-A" ]]; then
    var_arg="$2"
    shift 2
  fi

  if [[ "$var_arg" == "" ]]; then
    stdlib_argparser error/missing_arg "-A"
    return 1
  fi

  kv -A "${var_arg}" -s "=" < <(printf "%s" "$1")
}
