stdlib_error_log() {
  local caller="${BASH_SOURCE[1]}:${BASH_LINENO[2]}"

  printf "bash+stdlib error: %s: $1\n" "${caller}" "${@:2}" >&2
}
