stdlib_import "duration"
stdlib_import "error"
stdlib_import "string/pluralize"
stdlib_import "maths"
stdlib_import "array/to_sentence"

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
    --years --months --weeks --days --hours --minutes --seconds --milliseconds --microseconds --nanoseconds \
    --total-years --total-months --total-weeks --total-days --total-hours --total-minutes --total-seconds --total-milliseconds --total-microseconds --total-nanoseconds)

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
  local microseconds="${duration_values[8]}"
  local nanoseconds="${duration_values[9]}"
  local total_years="${duration_values[10]}"
  local total_months="${duration_values[11]}"
  local total_weeks="${duration_values[12]}"
  local total_days="${duration_values[13]}"
  local total_hours="${duration_values[14]}"
  local total_minutes="${duration_values[15]}"
  local total_seconds="${duration_values[16]}"
  local total_milliseconds="${duration_values[17]}"
  local total_microseconds="${duration_values[18]}"
  local total_nanoseconds="${duration_values[19]}"

  # Process format string
  local result
  
  if [[ "$format_string" == "human" ]]; then
    # Check if input is a simple decimal number for smart unit selection
    if [[ "$duration_string" =~ ^[0-9]+\.?[0-9]*$ ]]; then
      local input_value="$duration_string"
      
      # Convert to total seconds for comparison
      local total_seconds_val="${duration_values[16]}"
      
      # Choose the most appropriate unit based on magnitude
      # Special case for zero
      if ${ stdlib_maths --quiet "$total_seconds_val == 0"; }; then
        result="0 seconds"
      elif ${ stdlib_maths --quiet "$total_seconds_val >= 1"; }; then
        # 1 second or more - check for nice conversions to larger units
        local should_convert_up=false
        local converted_result=""
        
        # Check for exact conversions to larger units (only for integer inputs)
        if [[ ! "$input_value" =~ \. ]]; then
          # Years (31536000 seconds)
          if ${ stdlib_maths --quiet "$total_seconds_val % 31536000 == 0"; }; then
            local year_value=${ stdlib_maths "$total_seconds_val / 31536000"; }
            converted_result="$year_value $(stdlib_string_pluralize "year" "$year_value")"
            should_convert_up=true
          # Months (2592000 seconds = 30 days)
          elif ${ stdlib_maths --quiet "$total_seconds_val % 2592000 == 0"; }; then
            local month_value=${ stdlib_maths "$total_seconds_val / 2592000"; }
            converted_result="$month_value $(stdlib_string_pluralize "month" "$month_value")"
            should_convert_up=true
          # Weeks (604800 seconds)
          elif ${ stdlib_maths --quiet "$total_seconds_val % 604800 == 0"; }; then
            local week_value=${ stdlib_maths "$total_seconds_val / 604800"; }
            converted_result="$week_value $(stdlib_string_pluralize "week" "$week_value")"
            should_convert_up=true
          # Days (86400 seconds)
          elif ${ stdlib_maths --quiet "$total_seconds_val % 86400 == 0"; }; then
            local day_value=${ stdlib_maths "$total_seconds_val / 86400"; }
            converted_result="$day_value $(stdlib_string_pluralize "day" "$day_value")"
            should_convert_up=true
          # Hours (3600 seconds)
          elif ${ stdlib_maths --quiet "$total_seconds_val % 3600 == 0"; }; then
            local hour_value=${ stdlib_maths "$total_seconds_val / 3600"; }
            converted_result="$hour_value $(stdlib_string_pluralize "hour" "$hour_value")"
            should_convert_up=true
          # Minutes (60 seconds)
          elif ${ stdlib_maths --quiet "$total_seconds_val % 60 == 0"; }; then
            local minute_value=${ stdlib_maths "$total_seconds_val / 60"; }
            converted_result="$minute_value $(stdlib_string_pluralize "minute" "$minute_value")"
            should_convert_up=true
          fi
        fi
        
        if [[ "$should_convert_up" == true ]]; then
          result="$converted_result"
        else
          # No exact conversion - use multi-component breakdown
          if [[ "$input_value" =~ \. ]]; then
            # Decimal input - break down into components (1.5 -> 1 second and 500ms)
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
            
            if [[ "$seconds" -gt 0 ]]; then
              readable_parts+=("$seconds $(stdlib_string_pluralize "second" "$seconds")")
            fi
            
            # Add milliseconds if present
            if [[ "$milliseconds" -gt 0 ]]; then
              readable_parts+=("${milliseconds}ms")
            fi
            
            # Add microseconds if present (and no milliseconds to avoid clutter)
            if [[ "$microseconds" -gt 0 ]] && [[ "$milliseconds" -eq 0 ]]; then
              readable_parts+=("${microseconds}μs")
            fi
            
            # Add nanoseconds if present (and no milliseconds/microseconds to avoid clutter)
            if [[ "$nanoseconds" -gt 0 ]] && [[ "$milliseconds" -eq 0 ]] && [[ "$microseconds" -eq 0 ]]; then
              readable_parts+=("${nanoseconds}ns")
            fi
            
            # Join components
            if [[ ${#readable_parts[@]} -eq 0 ]]; then
              result="0 seconds"
            else
              result=$(stdlib_array_to_sentence "${readable_parts[@]}")
            fi
          else
            # Integer input that doesn't convert evenly - use traditional human format
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
            
            if [[ "$seconds" -gt 0 ]] || [[ ${#readable_parts[@]} -eq 0 ]]; then
              readable_parts+=("$seconds $(stdlib_string_pluralize "second" "$seconds")")
            fi
            
            # Join with commas and "and" for the last item
            if [[ ${#readable_parts[@]} -eq 0 ]]; then
              result="0 seconds"
            else
              result=$(stdlib_array_to_sentence "${readable_parts[@]}")
            fi
          fi
        fi
      elif ${ stdlib_maths --quiet "$total_seconds_val >= 0.001"; }; then
        # 1ms or more - use milliseconds, always round to whole numbers
        local ms_value=${ stdlib_maths "round($total_seconds_val * 1000)"; }
        result="${ms_value}ms"
      elif ${ stdlib_maths --quiet "$total_seconds_val >= 0.000001"; }; then
        # 1μs or more - use microseconds, always round to whole numbers  
        local us_value=${ stdlib_maths "round($total_seconds_val * 1000000)"; }
        result="${us_value}μs"
      else
        # Less than 1μs - use nanoseconds, always round to whole numbers
        local ns_value=${ stdlib_maths "round($total_seconds_val * 1000000000)"; }
        result="${ns_value}ns"
      fi
    else
      # Not a simple decimal - check if we can preserve the original unit
      local should_preserve_unit=false
      local preserved_result=""
      
      # Check for single unit inputs that should be preserved
      if [[ "$duration_string" =~ ^[0-9]+\.?[0-9]*ms$ ]]; then
        # Input was in milliseconds - preserve if it makes sense
        local ms_input="${duration_string%ms}"
        if [[ "$milliseconds" -eq "$ms_input" ]] && [[ "$seconds" -eq 0 ]]; then
          preserved_result="${ms_input}ms"
          should_preserve_unit=true
        fi
      elif [[ "$duration_string" =~ ^[0-9]+\.?[0-9]*(μs|us)$ ]]; then
        # Input was in microseconds - preserve if it makes sense
        local us_input="${duration_string%μs}"
        us_input="${us_input%us}"
        if [[ "$microseconds" -eq "$us_input" ]] && [[ "$seconds" -eq 0 ]] && [[ "$milliseconds" -eq 0 ]]; then
          preserved_result="${us_input}μs"
          should_preserve_unit=true
        fi
      elif [[ "$duration_string" =~ ^[0-9]+\.?[0-9]*(ns)$ ]]; then
        # Input was in nanoseconds - preserve if it makes sense
        local ns_input="${duration_string%ns}"
        if [[ "$nanoseconds" -eq "$ns_input" ]] && [[ "$seconds" -eq 0 ]] && [[ "$milliseconds" -eq 0 ]] && [[ "$microseconds" -eq 0 ]]; then
          preserved_result="${ns_input}ns"
          should_preserve_unit=true
        fi
      fi
      
      if [[ "$should_preserve_unit" == true ]]; then
        result="$preserved_result"
      else
        # Use traditional human format
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
    
    if [[ "$seconds" -gt 0 ]] || [[ "$milliseconds" -gt 0 ]] || [[ "$microseconds" -gt 0 ]] || [[ "$nanoseconds" -gt 0 ]] || [[ ${#readable_parts[@]} -eq 0 ]]; then
      if [[ "$milliseconds" -gt 0 ]] || [[ "$microseconds" -gt 0 ]] || [[ "$nanoseconds" -gt 0 ]]; then
        local total_fractional_seconds=${ stdlib_maths "$seconds + ($milliseconds / 1000) + ($microseconds / 1000000) + ($nanoseconds / 1000000000)"; }
        # Add leading zero if missing and clean up trailing zeros
        if [[ "$total_fractional_seconds" =~ ^\. ]]; then
          total_fractional_seconds="0$total_fractional_seconds"
        fi
        # Format with appropriate precision and remove trailing zeros
        if [[ "$total_fractional_seconds" =~ \. ]]; then
          total_fractional_seconds=$(printf "%.9f" "$total_fractional_seconds" | sed 's/0*$//' | sed 's/\.$/.0/')
        fi
        readable_parts+=("$total_fractional_seconds $(stdlib_string_pluralize "second" "$total_fractional_seconds")")
      else
        readable_parts+=("$seconds $(stdlib_string_pluralize "second" "$seconds")")
      fi
    fi
    
    # Join with commas and "and" for the last item
    if [[ ${#readable_parts[@]} -eq 0 ]]; then
      result="0 seconds"
    else
      result=$(stdlib_array_to_sentence "${readable_parts[@]}")
    fi
      fi
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