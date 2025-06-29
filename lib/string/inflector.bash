inflector() {
  local inflection="$1"
  shift

  local returnvar
  if [[ "$1" == "-v" ]]; then
    returnvar="$2"
    shift 2
  fi

  local str="${1:-$(</dev/stdin)}"

  case "$inflection" in
  capitalize)
    local first_char="${str:0:1}"
    local rest_of_string="${str:1}"

    first_char="${first_char^^}"
    rest_of_string="${rest_of_string,,}"

    str="${first_char}${rest_of_string}"
    ;;
  lowercase)
    str="${str,,}"
    ;;
  uppercase)
    str="${str^^}"
    ;;
  esac

  if [[ -n "$returnvar" ]]; then
    declare -n returnvar_ref="${returnvar}"
    # shellcheck disable=SC2034
    returnvar_ref="${str}"
  else
    printf "%s\n" "${str}"
  fi
}
