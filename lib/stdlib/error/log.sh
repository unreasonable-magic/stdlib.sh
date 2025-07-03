stdlib::error::log() {
  local -r script_name="$(basename "$0")"

  printf "%s: $1\n" "$script_name" "${@:2}" >&2
}
