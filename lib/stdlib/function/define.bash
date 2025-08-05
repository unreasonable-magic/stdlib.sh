stdlib_import "test"
stdlib_import "function/name"
stdlib_import "function/location"
stdlib_import "file/expandpath"

# Global counter for generating unique function names
declare -g __stdlib_function_define_counter=0

stdlib_function_define() {
  local quiet_arg
  if [[ "$1" == "--quiet" ]]; then
    quiet_arg=true
    shift
  fi

  local location="$1"
  local body="$2"

  # If only one argument provided, treat it as the body and generate a random name
  if [[ $# -eq 1 && "$1" != "-" ]] || [[ $# -eq 0 && ! -t 0 ]]; then
    body="$1"
    # Generate a unique function name using PID and counter
    ((__stdlib_function_define_counter++))
    location="fn_${$}_${__stdlib_function_define_counter}_${RANDOM}"
    
    # If no arguments and stdin is available, read body from stdin
    if [[ $# -eq 0 && ! -t 0 ]]; then
      IFS= read -d '' -r body
    fi
  elif [[ ("$body" == "" || "$body" == "-") && ! -t 0 ]]; then
    IFS= read -d '' -r body
  fi

  # Let's see what the location we've been provided looks like, and fill in the
  # blanks
  IFS=":" read -r -a segments <<< "$location"
  local -i segments_count="${#segments[@]}"

  # Make sure we've not been provided too many location segments
  if [[ $segments_count -gt 3 ]]; then
    stdlib_error_log "too many segments provided"
    return 1
  fi

  # You can only pass either a function name, or a fully qualified location
  if [[ $segments_count -eq 2 ]]; then
    stdlib_error_log "not enough segments. location must either be a function name, or a fully formed location: path:line:name"
    return 1
  fi

  local path line_number function_name

  # If we've only been given 1, then it's gotta be a function name
  if [[ $segments_count -eq 1 ]]; then
    function_name="${segments[0]}"

    if ! stdlib_function_name --quiet "$function_name"; then
      stdlib_error_log "invalid function name %s" "$function_name"
      return 1
    fi
  fi

  path="${ stdlib_file_expandpath "${BASH_SOURCE[1]}"; }"
  line_number="${BASH_LINENO[0]}"

  local location
  printf -v location "%s:%s:<%s>" "$path" "$line_number" "$function_name"

  local definition
  printf -v definition "%s() {\n%s\n}\n" \
    "$function_name" \
    "$body"

  local exit_code
  eval "$definition"
  exit_code="$?"

  if [[ ! "$exit_code" -eq 0 ]]; then
    return "$exit_code"
  fi

  stdlib_function_location_hints set "$function_name" "$location"

  if [[ "$quiet_arg" != true ]]; then
    printf "%s\n" "$function_name"
  fi

  return 0
}
