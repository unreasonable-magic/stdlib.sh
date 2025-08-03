enable fltexpr
stdlib_import "duration"

stdlib_maths() {
  local __stdlib_maths_result exit_code
  local format_string="$1"
  shift
  
  # Check if format string is provided
  if [[ -z "$format_string" ]]; then
    echo "stdlib_maths: error: no format string provided" >&2
    return 1
  fi
  
  # Create a working copy of the format string
  local expression="$format_string"
  local arg_index=0
  local -a args=("$@")
  
  # Process placeholders in order they appear
  while [[ "$expression" =~ (%[npd]) ]]; do
    if [[ $arg_index -ge ${#args[@]} ]]; then
      echo "stdlib_maths: error: not enough arguments for format string" >&2
      return 1
    fi
    
    local placeholder="${BASH_REMATCH[1]}"
    local arg="${args[$arg_index]}"
    
    if [[ "$placeholder" == "%p" ]]; then
      # Strip % sign if present and convert to decimal
      if [[ "$arg" =~ ^([0-9]+\.?[0-9]*)%?$ ]]; then
        local value="${BASH_REMATCH[1]}"
        expression="${expression/\%p/(${value}/100)}"
      else
        echo "stdlib_maths: error: invalid percentage value: $arg" >&2
        return 1
      fi
    elif [[ "$placeholder" == "%d" ]]; then
      # Convert duration to seconds using stdlib_duration
      local duration_seconds
      duration_seconds=$(stdlib_duration "$arg" --total-seconds)
      if [[ $? -eq 0 ]]; then
        expression="${expression/\%d/${duration_seconds}}"
      else
        echo "stdlib_maths: error: invalid duration format: $arg" >&2
        return 1
      fi
    else
      # %n - just replace with the argument value
      expression="${expression/\%n/${arg}}"
    fi
    
    ((arg_index++))
  done
  
  # Convert percentages (e.g., "50%" -> "(50/100)")
  # Match numbers followed by % sign, including decimals
  while [[ "$expression" =~ ([0-9]+\.?[0-9]*)% ]]; do
    local percentage="${BASH_REMATCH[1]}"
    expression="${expression//${BASH_REMATCH[0]}/(${percentage}/100)}"
  done
  
  # Convert "of" to multiplication
  expression="${expression// of / * }"
  
  # Check if the expression is a variable assignment (starts with identifier =)
  local is_assignment=false
  if [[ "$expression" =~ ^[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*= ]]; then
    is_assignment=true
  fi
  
  if [[ "$is_assignment" == true ]]; then
    # For assignments, execute directly with fltexpr
    fltexpr "$expression"
    exit_code="$?"
    if [[ ! "$exit_code" -eq 0 ]]; then
      echo "stdlib_maths: error: invalid mathematical expression: $expression" >&2
      return "$exit_code"
    fi
  else
    # For expressions, evaluate and print result
    fltexpr "__stdlib_maths_result = ($expression)"
    exit_code="$?"
    if [[ ! "$exit_code" -eq 0 ]]; then
      echo "stdlib_maths: error: invalid mathematical expression: $expression" >&2
      return "$exit_code"
    fi
    
    printf "%s\n" "$__stdlib_maths_result"
  fi
}
