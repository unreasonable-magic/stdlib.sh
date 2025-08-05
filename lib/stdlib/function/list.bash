stdlib_import "function/location"
stdlib_import "file/expandpath"

stdlib_function_list() {
  local pattern="*"
  local path_pattern=""
  local line_pattern=""
  local function_pattern=""
  local is_location_format=false
  
  # If an argument is provided, check if it's location-formatted
  if [[ $# -gt 0 ]]; then
    local arg="$1"
    
    # Check if argument contains colons (location format: path:line:function_name)
    if [[ "$arg" == *:*:* ]]; then
      is_location_format=true
      
      # Split the argument into path, line, and function parts
      IFS=':' read -r path_pattern line_pattern function_pattern <<< "$arg"
      
      # Validate that line pattern is only "*"
      if [[ "$line_pattern" != "*" ]]; then
        stdlib_error_log "line number must be '*', got: %s" "$line_pattern"
        return 1
      fi
      
      # Expand path pattern to absolute path for comparison
      path_pattern="${ stdlib_file_expandpath "$path_pattern"; }"
    else
      # Original format - just a function name pattern
      pattern="$arg"
    fi
  fi

  # Get all function names using declare -F
  local -a all_functions=()
  local line
  while IFS= read -r line; do
    # Extract function name from "declare -f function_name" format
    local func_name="${line#declare -f }"
    all_functions+=("$func_name")
  done < <(declare -F)

  # Filter functions based on pattern and output their locations
  local func_name
  for func_name in "${all_functions[@]}"; do
    if [[ "$is_location_format" == true ]]; then
      # Location format: filter by both path and function name
      local location
      location="${ stdlib_function_location "$func_name"; }"
      if [[ $? -eq 0 ]]; then
        # Parse the location to get path:line:function_name format
        local func_path func_line func_name_in_location
        IFS=':' read -r func_path func_line func_name_in_location <<< "$location"
        
        # Check if both path and function name match their patterns
        if [[ "$func_path" == $path_pattern && "$func_name_in_location" == $function_pattern ]]; then
          printf "%s\n" "$location"
        fi
      fi
    else
      # Original format: filter by function name pattern only
      if [[ "$func_name" == $pattern ]]; then
        local location
        location="${ stdlib_function_location "$func_name"; }"
        if [[ $? -eq 0 ]]; then
          printf "%s\n" "$location"
        fi
      fi
    fi
  done
}