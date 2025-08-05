stdlib_import "test"
stdlib_import "function/name"
stdlib_import "function/definition"
stdlib_import "function/define"
stdlib_import "function/location"

stdlib_function_wrap() {
  local quiet_arg
  if [[ "$1" == "--quiet" ]]; then
    quiet_arg=true
    shift
  fi

  local function_identifier="$1"
  local new_body="$2"

  # Read body from stdin if not provided or if "-" is specified
  if [[ ("$new_body" == "" || "$new_body" == "-") && ! -t 0 ]]; then
    IFS= read -d '' -r new_body
  fi

  # Extract function name from identifier (could be name or location format)
  local function_name
  if [[ "$function_identifier" == *:*:* ]]; then
    # Location format: path:line:function_name - extract the function name
    function_name="${function_identifier##*:}"
  else
    # Simple function name
    function_name="$function_identifier"
  fi

  # Validate function name
  if ! stdlib_function_name --quiet "$function_name"; then
    stdlib_error_log "invalid function name %s" "$function_name"
    return 1
  fi

  # Check if function exists
  if ! stdlib_test type/is_function "$function_name"; then
    stdlib_error_log "function %s does not exist" "$function_name"
    return 1
  fi

  # Get the original function body and location
  local original_body
  original_body="${ stdlib_function_definition --body "$function_name"; }"
  if [[ $? -ne 0 ]]; then
    stdlib_error_log "could not get definition for function %s" "$function_name"
    return 1
  fi

  # Get the original function location to preserve it
  local original_location
  original_location="${ stdlib_function_location "$function_name"; }"
  if [[ $? -ne 0 ]]; then
    stdlib_error_log "could not get location for function %s" "$function_name"
    return 1
  fi

  # Create the original function name, stripping any < > brackets
  local clean_function_name="${function_name#<}"
  clean_function_name="${clean_function_name%>}"
  local original_function_name="__original_${clean_function_name}"

  # Create the original function first
  stdlib_function_define --quiet "$original_function_name" "$original_body"
  if [[ $? -ne 0 ]]; then
    stdlib_error_log "could not create original function %s" "$original_function_name"
    return 1
  fi

  # Define the new wrapped function
  local output
  if [[ "$quiet_arg" == true ]]; then
    output="${ stdlib_function_define --quiet "$function_name" "$new_body"; }"
  else
    output="${ stdlib_function_define "$function_name" "$new_body"; }"
  fi
  local exit_code=$?

  if [[ $exit_code -ne 0 ]]; then
    return $exit_code
  fi

  # Set the location hint for the wrapped function to point to the original location
  # This ensures stdlib_function_location returns the original source location
  stdlib_function_location_hints set "$function_name" "$original_location"

  # Output the function name if not quiet
  if [[ "$quiet_arg" != true ]]; then
    printf "%s\n" "$output"
  fi

  return 0
}