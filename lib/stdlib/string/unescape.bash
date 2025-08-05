stdlib_import "string/dequote"

stdlib_string_unescape() {
  printf "%s\n" "${1@E}"
}
