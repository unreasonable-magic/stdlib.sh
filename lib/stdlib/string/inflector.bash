stdlib_string_inflector() {
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
  underscore)
    local new_str=""
    local char

    # Remove chars we don't care about
    str="${str//[^a-zA-Z0-9 ]/}"

    local new_str=""

    IFS=' ' read -ra words <<< "$str"
    for word in "${words[@]}"; do
      # If the word has a mixture of uppercase and lowercase, the explode it
      # into spaces, i.e. "myFoo" becomes "my Foo"
      if [[ "$word" =~ [a-z] && "$word" =~ [A-Z] ]]; then
        local exploded_word=""
        for ((i = 0; i < ${#word}; i++)); do
          char="${word:i:1}"
          if [[ ! "$char" =~ [a-z] ]]; then
            char="${word:i:1}"
            exploded_word+=" "
          fi
          exploded_word+="$char"
        done
        new_str+=" $exploded_word"
      else
        new_str+=" $word"
      fi
    done

    str="${new_str}"

    # Lowercase everything
    str="${str,,}"

    # Compress all whitespace and remove it from the start and the end
    str="${str//+( )/ }"
    str="${str#"${str%%[![:space:]]*}"}"
    str="${str%"${str##*[![:space:]]}"}"

    # Replace whitespace with underscores
    str="${str// /_}"

    ;;
  esac

  if [[ -n "$returnvar" ]]; then
    declare -g __stdlib_string_inflector_return_value="${str}"
    eval "$returnvar=\$__stdlib_string_inflector_return_value"
    unset __stdlib_string_inflector_return_value
  else
    printf "%s\n" "${str}"
  fi

  return 0
}
