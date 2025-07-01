inflector() {
  shopt -s extglob

  local inflection="$1"
  shift 1

  local returnvar
  if [[ "$1" == "-v" ]]; then
    returnvar="$2"
    shift 2
  fi

  # Check if we're in a subshell and trying to set a variable
  # if [[ $BASH_SUBSHELL -gt 0 && -n "$returnvar" ]]; then
  #   echo "Error: Cannot set variable '$returnvar' from within a pipe/subshell." >&2
  #   echo "Use process substitution instead: $inflection -v $returnvar < <(echo \"\$data\")" >&2
  #   echo "Or here-string: inflector $inflection -v $returnvar <<< \"\$data\"" >&2
  #   return 1
  # fi

  local str=""
  if [ $# -gt 0 ]; then
    str="$1"
  else
    str="$(
      cat </dev/stdin
      echo x
    )"
    str="${str%x}"
  fi

  case "$inflection" in
  capitalize)
    local first_char="${str:0:1}"
    local rest_of_string="${str:1}"

    first_char="${first_char^^}"
    rest_of_string="${rest_of_string,,}"

    str="${first_char}${rest_of_string}"
    ;;
  titleize)
    local result=""
    local char prev_char=" "

    for ((i = 0; i < ${#str}; i++)); do
      char="${str:i:1}"
      if [[ "$prev_char" =~ [^a-zA-Z] && "$char" =~ [a-zA-Z] ]]; then
        result+="${char^^}"
      elif [[ "$char" =~ [a-zA-Z] ]]; then
        result+="${char,,}"
      else
        result+="$char"
      fi
      prev_char="$char"
    done

    str="${result}"
    ;;
  lowercase)
    str="${str,,}"
    ;;
  uppercase)
    str="${str^^}"
    ;;
  trim)
    str="${str#"${str%%[![:space:]]*}"}"
    str="${str%"${str##*[![:space:]]}"}"
    ;;
  esac

  if [[ -n "$returnvar" ]]; then
    printf -v "$returnvar" "%s" "${str}"
  else
    printf "%s\n" "${str}"
  fi

  return 0
}
