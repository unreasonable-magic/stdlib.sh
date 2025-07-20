stdlib_import "string/escape"

stdlib_terminal_query() {
  local input="$1"
  local description="$2"

  # Save terminal settings
  local OLD_STTY=$(stty -g)

  # Set terminal to raw mode
  stty raw -echo min 0 time 10 # time 10 = 1 second timeout

  local query=""
  case "$input" in
    cursor)
      query="\e[6n"
      ;;
    #device_status_report)
    #  query="\e[5n"
    #  ;;
    # primary_device_attributes)
    #   query="\e[c"
    #   ;;
    # secondary_device_attributes)
    #   query="\e[>c"
    #   ;;
    # tertiary_device_attributes)
    #   query="\e[=c"
    #   ;;
    window_size_pixels)
      query="\e[14t"
      ;;
    window_size_characters)
      query="\e[18t"
      ;;
    terminal_size_characters)
      query="\e[18t"
      ;;
    terminal_size_pixels)
      query="\e[19t"
      ;;
    terminal_version)
      query="\e[>q"
      ;;
    window_title)
      query="\e[>q"
      ;;

  esac

  # Send query
  printf "%b" "$query" >&2

  # Read response character by character
  local response=""
  local char
  local count=0

  while [[ $count -lt 50 ]]; do # Max 50 characters
    if read -r -n1 char; then
      if [[ -z "$char" ]]; then
        break # Timeout
      fi
      response+="$char"

      # Check for common terminators
      case "$char" in
      'R' | 'c' | 't' | $'\007' | $'\\')
        # Common terminal response endings
        break
        ;;
      esac
    else
      break
    fi
    count=$((count + 1))
  done

  # Restore terminal settings
  stty "$OLD_STTY"

  if [[ -n "$response" ]]; then
    pp response
    printf "%s\n" "${ stdlib_string_escape "$response"; }"
  else
    printf "%-30s: <no response>\n" "$description"
  fi
}
