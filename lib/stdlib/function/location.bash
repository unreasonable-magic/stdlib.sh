stdlib_import "error"
stdlib_import "file/expandpath"
stdlib_import "test"

stdlib_function_location() {
  local input

  # Either use the function passed into $1, or the calling function
  if [[ $# -gt 0 ]]; then
    input="$1"
    shift
  else
    input="${FUNCNAME[1]}"

    # If there's something on stdin to read, and this stdlib_function_location
    # is being called from the main program (which is unsupported) or something
    # went wrong and it returned blank, let's use `-` (which in turn, will read
    # from stdin)
    if [[ "$input" == "" || "$input" == "main" ]]; then
      if [[ ! -t 0 ]]; then
        input="-"
      else
        stdlib_error_log "not inside function"
        return 1
      fi
    fi
  fi

  if [[ "$input" == "-" && ! -t 0 ]]; then
    read -r input
  fi

  # Before we go parsing anytihng, maybe there's a hint we can just pull from.
  # Hints can be set from anywhere, but they're usually when you dynamically
  # define a function with `stdlib_function_define`
  local hint="${ stdlib_function_location_hints get "$input"; }"
  if [[ "$hint" != "" ]]; then
    printf "%s\n" "$hint"
    return
  fi

  # Let's see what we've been given
  IFS=":" read -r -a parts <<< "$input"
  local -i parts_count="${#parts[@]}"

  if [[ $parts_count -gt 3 ]]; then
    stdlib_error_log "too many parts provided"
    return 1
  fi

  # If we've already been given something that already looks like a function
  # location, then let's just return that.
  if [[ $parts_count -eq 3 ]]; then
    # Make sure it wasn't actually the name of a function (since blah:12 is a
    # valid path and blah:12 is a valid bash function)
    if ! declare -f "$input" >/dev/null; then
      printf "$input\n"
      return
    fi
  fi

  # Let's start by checking the first element to see if it's a path to a
  # function
  local location="${ stdlib_file_expandpath "${parts[0]}"; }"

  # If the path doesn't exist, then it must be in memory
  if ! stdlib_test file/exists "${location}"; then
    local declaration exit_code

    shopt -s extdebug
    declaration="${ declare -F "$input"; }"
    exit_code="$?"
    shopt -u extdebug

    if [[ ! "$exit_code" -eq 0 ]]; then
      stdlib_error "could not lookup source of $input"
      return 1
    fi

    if [[ "$declaration" =~ ^([^ ]+)[[:space:]]+([0-9]+)[[:space:]]+(.+)$ ]]; then
      local expanded_path="${ stdlib_file_expandpath "${BASH_REMATCH[3]}"; }"
      printf "%s:%s:%s\n" "$expanded_path" "${BASH_REMATCH[2]}" "${BASH_REMATCH[1]}"
      return 
    else
      stdlib_error "invalid format returned from declare -F $input ($declaration)"
      return 1
    fi
  fi

  # If both the path exists, and there's a function in memory with the same
  # name, just error out and say it's too hard
  if declare -f "$input" >/dev/null; then
    stdlib_error_log "ambigious input: there's both a file name and function called $input"
    return 1
  fi

  # If we're here, that means we have a valid location, now let's see if we have
  # either a line number or function name to look for
  local line_number
  local function_name

  local -a lines=()

  if stdlib_test type/is_number "${parts[1]}"; then
    # It's a file number, let's read that line in and see if we have a function
    # name
    line_number="${parts[1]}"

    # This reads a single line by starting the "read" from the line before, and
    # only reading 1 line. So much reading!
    mapfile -t -s $((line_number-1)) -n 1 lines < "$location"
    local line="${lines[0]}"

    # Check if the line is a function declaration
    if [[ "$line" =~ ^([a-zA-Z0-9_]+)[[:space:]]*\(\)[[:space:]]*\{$ ]]; then
      # Huzzah, it is!
      function_name="${BASH_REMATCH[1]}"
    else
      stdlib_error_log "$line is not a valid function definition"
      return 1
    fi
  else
    # If this function name is blank, we'll just return the first one we find
    function_name="${parts[1]}"

    mapfile -t lines < "$location"

    local -i current_line_number=1
    for line in "${lines[@]}"; do
      if [[ "$line" =~ ^([a-zA-Z0-9_]+)[[:space:]]*\(\)[[:space:]]*\{$ ]]; then
        local found_function_name="${BASH_REMATCH[1]}"

        # We're we looking for a function name?
        if [[ "$function_name" != "" ]]; then
          if [[ "$function_name" == "$found_function_name" ]]; then
            line_number="$current_line_number"
            break
          fi
        else
          # No function name means just return the first one we found
          function_name="$found_function_name"
          line_number="$current_line_number"
          break
        fi
      fi

      ((current_line_number++))
    done

    if [[ "$function_name" != "" && "$line_number" == "" ]]; then
      stdlib_error_log "couldn't find $function_name in $location"
      return 1
    elif [[ "$function_name" == "" && "$line_number" == "" ]]; then
      stdlib_error_log "no functions defined in $location"
      return 1
    fi
  fi

  printf "%s:%s:%s\n" "$location" "$line_number" "$function_name"
}

stdlib_function_location_hints() {
  declare -A -g __stdlib_function_location_hints=()

  stdlib_function_location_hints() {
    case "$1" in
      set)
        __stdlib_function_location_hints["$2"]="$3"
        ;;

      get)
        printf "%s\n" "${__stdlib_function_location_hints["$2"]}"
        ;;

      size)
        printf "%s\n" "${#__stdlib_function_location_hints[@]}"
        ;;

      ls)
        local key buffer
        for key in "${!__stdlib_function_location_hints[@]}"; do
          buffer+="${key}=${__stdlib_function_location_hints["$key"]}"$'\n'
        done
        printf "%s" "$buffer"
        ;;

      *)
        stdlib_argparser error/invalid_arg "$2"
        return 1
    esac
  }

  stdlib_function_location_hints "$@"
}
