stdlib_import "argparser"
stdlib_import "string/repeat"

stdlib_string_indent() {
  if [[ $# -eq 1 ]]; then
    local indent_count_arg="$1"
  elif [[ $# -eq 2 ]]; then
    local str="$1"
    local indent_count_arg="$2"
  else
    stdlib_argparser error/length_mismatch 2
    return 1
  fi

  local spaces="${ stdlib_string_repeat " " "${indent_count_arg}"; }"
  local line

  if [[ -n "$str" ]]; then
    while IFS= read -r line; do
      printf "%s%s\n" "$spaces" "$line"
    done <<< "$str"
  else
    while IFS= read -r line || [[ -n "$line" ]]; do
      printf "%s%s\n" "$spaces" "$line"
    done
  fi
}
