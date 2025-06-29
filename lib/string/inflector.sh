#!/usr/bin/env sh

inflector() {
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
    first_char="$(printf '%s' "$str" | cut -c1)"
    rest_of_string="$(printf '%s' "$str" | cut -c2-)"
    uppercase -v first_char "$first_char"
    lowercase -v rest_of_string "$rest_of_string"
    str="${first_char}${rest_of_string}"
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
