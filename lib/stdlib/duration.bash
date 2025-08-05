stdlib_import "error"
stdlib_import "duration/format"
stdlib_import "maths"

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
    total_milliseconds=${ stdlib_maths "$input * 1000"; }
  else
    # Remove extra spaces and normalize
    temp_input=$(echo "$temp_input" | tr -s ' ')
    
    # Parse each time unit
    while [[ -n "$temp_input" ]]; do
      # Try to match a number followed by a unit
      if [[ "$temp_input" =~ ^[[:space:]]*([0-9]+\.?[0-9]*)[[:space:]]*(nanosecond|nanoseconds|ns|microsecond|microseconds|μs|us|millisecond|milliseconds|ms|second|seconds|sec|s|minute|minutes|min|m|hour|hours|hr|h|day|days|d|week|weeks|w|month|months|mo|year|years|yr|y)[[:space:]]* ]]; then
        local value="${BASH_REMATCH[1]}"
        local unit="${BASH_REMATCH[2]}"
        local matched="${BASH_REMATCH[0]}"
        
        # Convert to seconds based on unit
        case "$unit" in
          nanosecond|nanoseconds|ns)
            total_seconds=${ stdlib_maths "$total_seconds + ($value / 1000000000)"; }
            ;;
          microsecond|microseconds|μs|us)
            total_seconds=${ stdlib_maths "$total_seconds + ($value / 1000000)"; }
            ;;
          millisecond|milliseconds|ms)
            total_seconds=${ stdlib_maths "$total_seconds + ($value / 1000)"; }
            ;;
          second|seconds|sec|s)
            total_seconds=${ stdlib_maths "$total_seconds + $value"; }
            ;;
          minute|minutes|min|m)
            total_seconds=${ stdlib_maths "$total_seconds + ($value * 60)"; }
            ;;
          hour|hours|hr|h)
            total_seconds=${ stdlib_maths "$total_seconds + ($value * 3600)"; }
            ;;
          day|days|d)
            total_seconds=${ stdlib_maths "$total_seconds + ($value * 86400)"; }
            ;;
          week|weeks|w)
            total_seconds=${ stdlib_maths "$total_seconds + ($value * 604800)"; }
            ;;
          month|months|mo)
            # Approximate: 30 days per month
            total_seconds=${ stdlib_maths "$total_seconds + ($value * 2592000)"; }
            ;;
          year|years|yr|y)
            # Approximate: 365 days per year
            total_seconds=${ stdlib_maths "$total_seconds + ($value * 31536000)"; }
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
    total_milliseconds=${ stdlib_maths "$total_seconds * 1000"; }
  fi

  # Calculate component values
  local temp_seconds=$total_seconds
  
  # Years
  local years=${ stdlib_maths "floor($temp_seconds / 31536000)"; }
  temp_seconds=${ stdlib_maths "$temp_seconds - ($years * 31536000)"; }
  
  # Months (approximate: 30 days)
  local months=${ stdlib_maths "floor($temp_seconds / 2592000)"; }
  temp_seconds=${ stdlib_maths "$temp_seconds - ($months * 2592000)"; }
  
  # Weeks
  local weeks=${ stdlib_maths "floor($temp_seconds / 604800)"; }
  temp_seconds=${ stdlib_maths "$temp_seconds - ($weeks * 604800)"; }
  
  # Days
  local days=${ stdlib_maths "floor($temp_seconds / 86400)"; }
  temp_seconds=${ stdlib_maths "$temp_seconds - ($days * 86400)"; }
  
  # Hours
  local hours=${ stdlib_maths "floor($temp_seconds / 3600)"; }
  temp_seconds=${ stdlib_maths "$temp_seconds - ($hours * 3600)"; }
  
  # Minutes
  local minutes=${ stdlib_maths "floor($temp_seconds / 60)"; }
  temp_seconds=${ stdlib_maths "$temp_seconds - ($minutes * 60)"; }
  
  # Seconds (integer part only)
  local seconds=${ stdlib_maths "floor($temp_seconds)"; }
  
  # Extract fractional components
  local milliseconds=0
  local microseconds=0
  local nanoseconds=0
  
  if [[ "$temp_seconds" =~ \. ]]; then
    local fractional_part=${ stdlib_maths "$temp_seconds - $seconds"; }
    
    # Milliseconds (first 3 decimal places)
    milliseconds=${ stdlib_maths "floor($fractional_part * 1000)"; }
    local remaining_fractional=${ stdlib_maths "$fractional_part - ($milliseconds / 1000)"; }
    
    # Microseconds (next 3 decimal places)
    microseconds=${ stdlib_maths "floor($remaining_fractional * 1000000)"; }
    remaining_fractional=${ stdlib_maths "$remaining_fractional - ($microseconds / 1000000)"; }
    
    # Nanoseconds (next 3 decimal places)
    nanoseconds=${ stdlib_maths "floor($remaining_fractional * 1000000000)"; }
    
    # Adjust for overflow (if microseconds >= 1000, add to milliseconds, etc.)
    if (( microseconds >= 1000 )); then
      milliseconds=$((milliseconds + microseconds / 1000))
      microseconds=$((microseconds % 1000))
    fi
    
    if (( nanoseconds >= 1000 )); then
      microseconds=$((microseconds + nanoseconds / 1000))
      nanoseconds=$((nanoseconds % 1000))
    fi
  fi

  # Calculate total values
  local total_minutes=${ stdlib_maths "floor($total_seconds / 60)"; }
  local total_hours=${ stdlib_maths "floor($total_seconds / 3600)"; }
  local total_days=${ stdlib_maths "floor($total_seconds / 86400)"; }
  local total_weeks=${ stdlib_maths "floor($total_seconds / 604800)"; }
  local total_months=${ stdlib_maths "floor($total_seconds / 2592000)"; }
  local total_years=${ stdlib_maths "floor($total_seconds / 31536000)"; }
  local total_microseconds=${ stdlib_maths "floor($total_seconds * 1000000)"; }
  local total_nanoseconds=${ stdlib_maths "floor($total_seconds * 1000000000)"; }

  local -a parts=()

  # If no options specified, return human-readable format using stdlib_duration_format
  if [[ $# -eq 0 ]]; then
    local formatted_result
    formatted_result=$(stdlib_duration_format "$input")
    parts+=("$formatted_result")
  else
    for arg in "$@"; do
      case "$arg" in
      --nanoseconds|--ns)
        parts+=("$nanoseconds")
        ;;
      --microseconds|--μs|--us)
        parts+=("$microseconds")
        ;;
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
      --total-nanoseconds|--total-ns)
        parts+=("$total_nanoseconds")
        ;;
      --total-microseconds|--total-μs|--total-us)
        parts+=("$total_microseconds")
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