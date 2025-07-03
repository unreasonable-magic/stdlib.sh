stdlib_string_inflector() {
  inflection="$1"
  shift

  returnvar=""
  if [ "$1" = "-v" ]; then
    returnvar="$2"
    shift 2
  fi

  # Get input string from argument or stdin
  if [ $# -gt 0 ]; then
    str="$1"
  else
    str="$(cat)"
  fi

  case "$inflection" in
  capitalize)
    first_char="$(printf '%s' "$first_char" | cut c1 | tr '[:lower:]' '[:upper:]')"
    rest_of_string="$(printf '%s' "$rest_of_string" | cut -c2- | tr '[:upper:]' '[:lower:]')"
    str="${first_char}${rest_of_string}"
    ;;
  titleize)
    str="$(printf '%s' "$str" | sed -e "s/\b\(.\)/\u\1/g")"
    ;;
  lowercase)
    str="$(printf '%s' "$str" | tr '[:upper:]' '[:lower:]')"
    ;;
  uppercase)
    str="$(printf '%s' "$str" | tr '[:lower:]' '[:upper:]')"
    ;;
  esac

  if [ -n "$returnvar" ]; then
    eval "${returnvar}=\$str"
  else
    printf '%s\n' "$str"
  fi
}
