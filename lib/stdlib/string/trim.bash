stdlib_import "string/trim_start"
stdlib_import "string/trim_end"

stdlib_string_trim() {
  local trimmed="${ stdlib_string_trim_start "$@"; }"
  printf "%s" "${ stdlib_string_trim_end "$trimmed"; }"
}
