stdlib_import "string/dequote"

stdlib_string_escape() {
  local escaped="${1@Q}"

  # Remove leading $ if one was added
  escaped="${escaped#\$}"

  # Remove the single quotes added by @Q
  stdlib_string_dequote "$escaped"
}
