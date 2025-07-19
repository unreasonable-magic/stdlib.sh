stdlib_import "array/join"
stdlib_import "string/quote"
stdlib_import "string/escape"
stdlib_import "string/count"

stdlib_array_serialize() {
  local arg_type=""
  local -n arg_ref
  local delim=$'\n'

  if [[ "$1" == "--compact" ]]; then
    delim=" "
    shift
  fi

  local serialized_key
  local serialized_value

  while [[ $# -gt 0 ]]; do
    declare -a buffer=()

    arg_type="$1"
    arg_ref="$2"
    shift 2

    case "$arg_type" in
      -A|-a)
        for key in "${!arg_ref[@]}"; do
          serialized_key="${ stdlib_string_escape "$key"; }"
          if [[ "$serialized_key" =~ [\ =\"\'] ]]; then
            serialized_key="${ stdlib_string_quote "$serialized_key"; }"
          fi

          serialized_value="${ stdlib_string_escape "${arg_ref["$key"]}"; }"
          if [[ "$serialized_value" =~ [\ =\"\'] ]]; then
            serialized_value="${ stdlib_string_quote "$serialized_value"; }"
          fi

          buffer+=("${serialized_key}=${serialized_value}")
        done
        ;;
      *)
        stdlib_argparser error/invalid_arg "$arg_type"
        return 1
        ;;
    esac

    # Skip empty buffers
    if [[ ${#buffer} -eq 0 ]]; then
      continue
    fi

    printf "%s\n" "${ stdlib_array_join --delim "$delim" -a buffer; }"
  done
}
