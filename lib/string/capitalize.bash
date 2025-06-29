stdlib::import "string/uppercase"
stdlib::import "string/lowercase"

capitalize() {
  local returnvar
  if [[ "$1" == "-v" ]]; then
    returnvar="$2"
    shift 2
  fi

  local str="${1:-$(</dev/stdin)}"

  local first_char="${str:0:1}"
  local rest_of_string="${str:1}"

  uppercase -v first_char "${first_char}"
  lowercase -v rest_of_string "${rest_of_string}"

  str="${first_char}${rest_of_string}"

  if [[ -n "$returnvar" ]]; then
    declare -n returnvar_ref="${returnvar}"
    # shellcheck disable=SC2034
    returnvar_ref="${str}"
  else
    printf "%s\n" "${str}"
  fi
}
