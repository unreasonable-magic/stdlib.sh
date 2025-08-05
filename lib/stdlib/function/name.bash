stdlib_function_name() {
  local quiet_arg
  if [[ "$1" == "--quiet" ]]; then
    quiet_arg=true
    shift
  fi

  local name="$1"
  local -i exit_code=0

  if [[ "$name" =~ ^\<?[a-zA-Z_][a-zA-Z0-9_]*\>?$ ]]; then
    # This is a bit gross, and could do with a refactor, but we're just making
    # sure that if there's a "<" at the start, i.e. an anonymous function, then
    # it also needs to end with a ">". I could probably do it in the regex, but
    # then it gets more annoying and complicated cause I'd need 2 different
    # ones.
    local first_char="${name:0:1}"
    local last_char="${name:$((${#name}-1)):1}"
    if [[ "$first_char" == "<" || "$last_char" == ">" ]]; then
      if [[ "$first_char" != "<" || "$last_char" != ">" ]]; then
        exit_code=1
      fi
    fi

    # Only print the name if it was valid
    if [[ $exit_code -eq 0 && "$quiet_arg" == "" ]]; then
      printf "%s\n" "$name"
    fi
  else
    exit_code=1
  fi

  return $exit_code
}
