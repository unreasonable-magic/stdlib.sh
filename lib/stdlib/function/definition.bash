stdlib_import "string/strip_prefix"
stdlib_import "string/strip_suffix"
stdlib_import "string/dedent"
stdlib_import "test"
stdlib_import "error"
stdlib_import "function/location"

stdlib_function_definition() {
  local -a formats=()
  local input

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --comment)
        formats+=("comment")
        shift
        ;;
      --declaration)
        formats+=("declaration")
        shift
        ;;
      --body)
        formats+=("body")
        shift
        ;;
      *)
        input="$1"
        shift
        break
        ;;
    esac
  done

  # Read from stdin if nothing was passed (and there's something to read)
  if [[ "$input" == "" || "$input" == "-" ]]; then
    if [[ ! -t 0 ]]; then
      read -r input
    fi
  fi

  if [[ -z "$input" ]]; then
    echo "Error: Function name or location required" >&2
    return 1
  fi

  # Make sure we have a valid location first
  local location exit_code
  location="${ stdlib_function_location "$input"; }"
  exit_code="$?"
  if [[ ! "$exit_code" -eq 0 ]]; then
    return "$exit_code"
  fi

  local -a lines
  local target_line_number

  IFS=":" read -r path path_line_number function_name <<< "$location"

  # Either read from the file, or read from memory
  if [[ -e "${path}" && "${function_name:0:1}" != "<" ]]; then
    mapfile -t lines < "$path"
    # The lines array starts at 0, but the path_line_number starts at 1
    target_line_number=$((path_line_number-1))
  else
    local declared="${ declare -f "$input"; }"
    if [[ -z "$declared" ]]; then
      echo "Error: Function '$input' not found" >&2
      return 1
    fi
    mapfile -t lines <<< "$declared"
    target_line_number=0
  fi

  local function_comment function_open_line function_body function_close_line

  local line_number=0
  local line_count="${#lines[@]}"

  # TODO: actually keep track of all the sub functions that are opened,
  # currently this is just 1 for the main function we're readingg
  local -i function_stack=0

  while [[ $line_number -lt $line_count ]]; do
    local line="${lines[$line_number]}"

    # Are we inside the function?
    if [[ "$function_stack" -gt 0 ]]; then
      # Stop reading if we've reached the end of the function
      if [[ "$line" == "}" ]]; then
        ((function_stack--))

        # Was that the last one? If so, save the last line and finish the
        # loop, otherwise, keep reading
        if [[ "$function_stack" -eq 0 ]]; then
          function_close_line="$line"
          break
        fi
      fi

      function_body+="$line"$'\n'
    else
      # Read comments leading up to the target line
      if [[ "$line_number" -lt "$target_line_number" ]]; then
        # If we're not in the function yet, or have yet to reach the target
        # line, lets collect any preceeding comments for the "header
        # comment"
        if [[ "$line" =~ ^[[:space:]]*#.*$ ]]; then
          function_comment+="$line"$'\n'
        else
          # We require comments to touch the function for it to be
          # considered "header". This means that a comment like this:
          #
          #     # blah
          #     my_func() {
          #       ...
          #     }
          #
          # Not valid:
          #
          #     # blah
          #
          #     my_func() {
          #       ...
          #     }
          function_comment=""
        fi
      fi

      # Now we've reached the target line, let's make sure it's a function
      # declaration
      if [[ "$line_number" -eq "$target_line_number" ]]; then
        # Huzzah! It is, let's start reading
        if [[ "$line" =~ ^([a-zA-Z0-9_]+)[[:space:]]*\(\)[[:space:]]*\{?$ ]]; then
          ((function_stack++))
          function_open_line="$line"$'\n'
        else
          stdlib_error_log "$line is not a valid function declaration"
          return 1
        fi
      fi
    fi

    ((line_number++))
  done

  # If we reached the end of reading, and there was still a function in the
  # stack, that means we didn't close one properly
  if [[ $function_stack -ge 1 ]]; then
    stdlib_error_log "unclosed function detected in $path"
    return 1
  fi

  # If we don't have a custom format to show, let's return it all
  if [[ ${#formats[@]} -eq 0 ]]; then
    printf "%s%s%s%s\n" "${function_comment}" "${function_open_line}" "${function_body}" "${function_close_line}"
    return
  fi

  # Or let's print out what was asked of us
  for format in "${formats[@]}"; do
    case "$format" in
      comment)
        printf "%s" "${function_comment}"
        ;;
      declaration)
        printf "%s%s%s\n" "${function_open_line}" "${function_body}" "${function_close_line}"
        ;;
      body)
        local dedented_function_body="${ stdlib_string_dedent "$function_body"; }"
        printf "%s\n" "${dedented_function_body}"
        ;;
    esac
  done

  return 0
}
