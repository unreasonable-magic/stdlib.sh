stdlib_import "duration"
stdlib_import "error"
stdlib_import "string/pluralize"

stdlib_duration_format() {
  local returnvar
  if [[ "$1" == "-v" ]]; then
    returnvar="$2"
    shift 2
  fi

  local duration_string="$1"
  local format_string="$2"
  shift 2

  # Check if duration string is provided
  if [[ -z "$duration_string" ]]; then
    stdlib_error_warning "missing duration string"
    return 1
  fi
  
  # If no format string provided, use human-readable default
  if [[ -z "$format_string" ]]; then
    format_string="human"
  fi

  # Get all duration values
  local values
  values=$(stdlib_duration "$duration_string" \
    --years --months --weeks --days --hours --minutes --seconds --milliseconds \
    --total-years --total-months --total-weeks --total-days --total-hours --total-minutes --total-seconds --total-milliseconds)

  # Convert to array
  local -a duration_values
  mapfile -t duration_values <<< "$values"

  # Extract individual values
  local years="${duration_values[0]}"
  local months="${duration_values[1]}"
  local weeks="${duration_values[2]}"
  local days="${duration_values[3]}"
  local hours="${duration_values[4]}"
  local minutes="${duration_values[5]}"
  local seconds="${duration_values[6]}"
  local milliseconds="${duration_values[7]}"
  local total_years="${duration_values[8]}"
  local total_months="${duration_values[9]}"
  local total_weeks="${duration_values[10]}"
  local total_days="${duration_values[11]}"
  local total_hours="${duration_values[12]}"
  local total_minutes="${duration_values[13]}"
  local total_seconds="${duration_values[14]}"
  local total_milliseconds="${duration_values[15]}"

  # Process format string
  local result
  
  if [[ "$format_string" == "human" ]]; then
    # Generate human-readable format
    local -a readable_parts=()
    
    if [[ "$years" -gt 0 ]]; then
      readable_parts+=("$years $(stdlib_string_pluralize "year" "$years")")
    fi
    
    if [[ "$months" -gt 0 ]]; then
      readable_parts+=("$months $(stdlib_string_pluralize "month" "$months")")
    fi
    
    if [[ "$weeks" -gt 0 ]]; then
      readable_parts+=("$weeks $(stdlib_string_pluralize "week" "$weeks")")
    fi
    
    if [[ "$days" -gt 0 ]]; then
      readable_parts+=("$days $(stdlib_string_pluralize "day" "$days")")
    fi
    
    if [[ "$hours" -gt 0 ]]; then
      readable_parts+=("$hours $(stdlib_string_pluralize "hour" "$hours")")
    fi
    
    if [[ "$minutes" -gt 0 ]]; then
      readable_parts+=("$minutes $(stdlib_string_pluralize "minute" "$minutes")")
    fi
    
    if [[ "$seconds" -gt 0 ]] || [[ "$milliseconds" -gt 0 ]] || [[ ${#readable_parts[@]} -eq 0 ]]; then
      if [[ "$milliseconds" -gt 0 ]]; then
        local total_fractional_seconds=$(echo "$seconds + ($milliseconds / 1000)" | bc -l)
        # Add leading zero if missing and clean up trailing zeros
        if [[ "$total_fractional_seconds" =~ ^\. ]]; then
          total_fractional_seconds="0$total_fractional_seconds"
        fi
        total_fractional_seconds=$(echo "$total_fractional_seconds" | sed 's/\.0*$//' | sed 's/\(\..*[^0]\)0*$/\1/')
        readable_parts+=("$total_fractional_seconds $(stdlib_string_pluralize "second" "$total_fractional_seconds")")
      else
        readable_parts+=("$seconds $(stdlib_string_pluralize "second" "$seconds")")
      fi
    fi
    
    # Join with commas and "and" for the last item
    if [[ ${#readable_parts[@]} -eq 0 ]]; then
      result="0 seconds"
    elif [[ ${#readable_parts[@]} -eq 1 ]]; then
      result="${readable_parts[0]}"
    elif [[ ${#readable_parts[@]} -eq 2 ]]; then
      result="${readable_parts[0]} and ${readable_parts[1]}"
    else
      local last_index=$((${#readable_parts[@]} - 1))
      local joined=""
      for ((i=0; i<last_index-1; i++)); do
        if [[ -n "$joined" ]]; then
          joined="$joined, ${readable_parts[i]}"
        else
          joined="${readable_parts[i]}"
        fi
      done
      joined="$joined, ${readable_parts[$((last_index-1))]} and ${readable_parts[$last_index]}"
      result="$joined"
    fi
  else
    # Process custom format string with placeholders
    result="$format_string"
    
    # Replace format specifiers
    # Total values first (to avoid conflicts with single-letter formats)
    # Replace longer patterns first to avoid partial matches
    result="${result//%tms/$total_milliseconds}"
    result="${result//%tmo/$total_months}"
    result="${result//%ty/$total_years}"
    result="${result//%tw/$total_weeks}"
    result="${result//%td/$total_days}"
    result="${result//%th/$total_hours}"
    result="${result//%tm/$total_minutes}"
    result="${result//%ts/$total_seconds}"
    result="${result//%t/$total_seconds}"
    
    # Component values - longer patterns first
    result="${result//%ms/$milliseconds}"
    result="${result//%mo/$months}"
    result="${result//%y/$years}"
    result="${result//%w/$weeks}"
    result="${result//%d/$days}"
    result="${result//%h/$hours}"
    result="${result//%m/$minutes}"
    result="${result//%s/$seconds}"
  fi

  if [[ -n "$returnvar" ]]; then
    declare -g "$returnvar"="$result"
  else
    printf "%s\n" "$result"
  fi

  return 0
}