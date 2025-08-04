stdlib_import "error"

stdlib_function_location() {
  local function_name

  while [[ $# -gt 0 ]]; do
    case "$1" in
      *)
        function_name="$1"
        shift
        break
        ;;
    esac
  done

  local location
  shopt -s extdebug
  location="${ declare -F "$function_name"; }"
  shopt -u extdebug

  if [[ "$location" =~ ^([^ ]+)[[:space:]]+([0-9]+)[[:space:]]+(.+)$ ]]; then
    printf "%s:%s\n" "${BASH_REMATCH[3]}" "${BASH_REMATCH[2]}"
  else
    stdlib_error "couldn't find function $function_name"
    return 1
  fi
}
