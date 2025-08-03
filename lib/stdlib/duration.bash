stdlib_import "error"
stdlib_import "duration/format"

stdlib_duration() {
  local returnvar
  if [[ "$1" == "-v" ]]; then
    returnvar="$2"
    shift 2
  fi

  local input
  
  # Check if input should come from stdin (no args or first arg starts with --)
  if [[ $# -eq 0 ]] || [[ "$1" =~ ^-- ]]; then
    # Try to read from stdin
    if [[ ! -t 0 ]]; then
      read -r input
    fi
  else
    # Use first argument as input
    input="$1"
    shift
  fi

  # Check if we got input from either source
  if [[ -z "$input" ]]; then
    stdlib_error_warning "no duration string passed"
    return 1
  fi

  local total_seconds=0
  local total_milliseconds=0
  local temp_input="$input"
  
  # Check if input is just a number (treat as seconds)
  if [[ "$input" =~ ^[0-9]+\.?[0-9]*$ ]]; then
    total_seconds="$input"
    # Calculate milliseconds
    total_milliseconds=$(printf "%.0f" $(echo "$input * 1000" | bc))
  else
    # Remove extra spaces and normalize
    temp_input=$(echo "$temp_input" | tr -s ' ')
    
    # Parse each time unit
    while [[ -n "$temp_input" ]]; do
      # Try to match a number followed by a unit
      if [[ "$temp_input" =~ ^[[:space:]]*([0-9]+\.?[0-9]*)[[:space:]]*(millisecond|milliseconds|ms|second|seconds|sec|s|minute|minutes|min|m|hour|hours|hr|h|day|days|d|week|weeks|w|month|months|mo|year|years|yr|y)[[:space:]]* ]]; then
        local value="${BASH_REMATCH[1]}"
        local unit="${BASH_REMATCH[2]}"
        local matched="${BASH_REMATCH[0]}"
        
        # Convert to seconds based on unit
        case "$unit" in
          millisecond|milliseconds|ms)
            total_seconds=$(printf "%.3f" $(echo "$total_seconds + ($value / 1000)" | bc -l))
            ;;
          second|seconds|sec|s)
            total_seconds=$(echo "$total_seconds + $value" | bc)
            ;;
          minute|minutes|min|m)
            total_seconds=$(echo "$total_seconds + ($value * 60)" | bc)
            ;;
          hour|hours|hr|h)
            total_seconds=$(echo "$total_seconds + ($value * 3600)" | bc)
            ;;
          day|days|d)
            total_seconds=$(echo "$total_seconds + ($value * 86400)" | bc)
            ;;
          week|weeks|w)
            total_seconds=$(echo "$total_seconds + ($value * 604800)" | bc)
            ;;
          month|months|mo)
            # Approximate: 30 days per month
            total_seconds=$(echo "$total_seconds + ($value * 2592000)" | bc)
            ;;
          year|years|yr|y)
            # Approximate: 365 days per year
            total_seconds=$(echo "$total_seconds + ($value * 31536000)" | bc)
            ;;
        esac
        
        # Remove matched part from input
        temp_input="${temp_input#$matched}"
      else
        # No more matches or invalid format
        break
      fi
    done
    
    # Calculate total milliseconds
    total_milliseconds=$(printf "%.0f" $(echo "$total_seconds * 1000" | bc))
  fi

  # Calculate component values
  local temp_seconds=$total_seconds
  
  # Years
  local years=$(echo "$temp_seconds / 31536000" | bc)
  temp_seconds=$(echo "$temp_seconds - ($years * 31536000)" | bc)
  
  # Months (approximate: 30 days)
  local months=$(echo "$temp_seconds / 2592000" | bc)
  temp_seconds=$(echo "$temp_seconds - ($months * 2592000)" | bc)
  
  # Weeks
  local weeks=$(echo "$temp_seconds / 604800" | bc)
  temp_seconds=$(echo "$temp_seconds - ($weeks * 604800)" | bc)
  
  # Days
  local days=$(echo "$temp_seconds / 86400" | bc)
  temp_seconds=$(echo "$temp_seconds - ($days * 86400)" | bc)
  
  # Hours
  local hours=$(echo "$temp_seconds / 3600" | bc)
  temp_seconds=$(echo "$temp_seconds - ($hours * 3600)" | bc)
  
  # Minutes
  local minutes=$(echo "$temp_seconds / 60" | bc)
  temp_seconds=$(echo "$temp_seconds - ($minutes * 60)" | bc)
  
  # Seconds (integer part only)
  local seconds=$(echo "$temp_seconds / 1" | bc)
  
  # Milliseconds (fractional part of remaining seconds * 1000)
  local milliseconds=0
  if [[ "$temp_seconds" =~ \. ]]; then
    local fractional_part=$(echo "$temp_seconds - $seconds" | bc -l)
    milliseconds=$(printf "%.0f" $(echo "$fractional_part * 1000" | bc))
  fi

  # Calculate total values
  local total_minutes=$(echo "$total_seconds / 60" | bc)
  local total_hours=$(echo "$total_seconds / 3600" | bc)
  local total_days=$(echo "$total_seconds / 86400" | bc)
  local total_weeks=$(echo "$total_seconds / 604800" | bc)
  local total_months=$(echo "$total_seconds / 2592000" | bc)
  local total_years=$(echo "$total_seconds / 31536000" | bc)

  local -a parts=()

  # If no options specified, return human-readable format using stdlib_duration_format
  if [[ $# -eq 0 ]]; then
    local formatted_result
    formatted_result=$(stdlib_duration_format "$input")
    parts+=("$formatted_result")
  else
    for arg in "$@"; do
      case "$arg" in
      --milliseconds|--ms)
        parts+=("$milliseconds")
        ;;
      --seconds)
        parts+=("$seconds")
        ;;
      --minutes)
        parts+=("$minutes")
        ;;
      --hours)
        parts+=("$hours")
        ;;
      --days)
        parts+=("$days")
        ;;
      --weeks)
        parts+=("$weeks")
        ;;
      --months)
        parts+=("$months")
        ;;
      --years)
        parts+=("$years")
        ;;
      --total-seconds)
        parts+=("$total_seconds")
        ;;
      --total-milliseconds|--total-ms)
        parts+=("$total_milliseconds")
        ;;
      --total-minutes)
        parts+=("$total_minutes")
        ;;
      --total-hours)
        parts+=("$total_hours")
        ;;
      --total-days)
        parts+=("$total_days")
        ;;
      --total-weeks)
        parts+=("$total_weeks")
        ;;
      --total-months)
        parts+=("$total_months")
        ;;
      --total-years)
        parts+=("$total_years")
        ;;
      esac
    done
  fi

  local IFS=$'\n'

  if [[ -n "$returnvar" ]]; then
    declare -g "$returnvar"="${parts[*]}"
  else
    echo -e "${parts[*]}"
  fi

  return 0
}