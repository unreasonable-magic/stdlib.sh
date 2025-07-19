stdlib_import "argparser"
stdlib_import "string/dequote"
stdlib_import "string/wordsplit"
stdlib_import "string/count"

enable kv

stdlib_array_deserialize() {
  local arr_type="$1"
  local -n -A arr_ref="$2"
  shift 2

  if [[ "$arr_type" != "-A" && "$arr_type" != "-a" ]]; then
    stdlib_argparser error/invalid_arg "$arr_type"
    return 1
  fi

  local input="$1"

  if [[ "${ stdlib_string_count "$input" $'\n'; }" -eq 0 ]]; then
    input="${ stdlib_string_wordsplit "$input"; }"
  fi

  local dequoted_key
  local dequoted_value

  kv -s "=" < <(printf "%s" "$input")
  pp KV
  pp arr_ref
  declare -p arr_ref
  for key in "${!KV[@]}"; do
    dequoted_key="${ stdlib_string_dequote "$key"; }"
    dequoted_value="${ stdlib_string_dequote "${KV["$key"]}"; }"

    pp dequoted_key
    pp dequoted_value

    arr_ref["$dequoted_key"]="$dequoted_value"
  done

  return 0
}
