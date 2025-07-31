stdlib_string_wrap() {
  local columns=80
  local returnvar=""
  local text=""
  local got_text=0
  
  # Parse all arguments
  while [ $# -gt 0 ]; do
    case "$1" in
      -v)
        returnvar="$2"
        shift 2
        ;;
      -c|--columns)
        columns="$2"
        shift 2
        ;;
      *)
        if [ $got_text -eq 0 ]; then
          text="$1"
          got_text=1
          shift
        else
          # Unexpected argument
          shift
        fi
        ;;
    esac
  done
  
  # If no text provided as argument, read from stdin
  if [ $got_text -eq 0 ]; then
    text="$(cat)"
  fi
  
  # If text is empty, just return empty
  if [ -z "$text" ]; then
    if [ -n "$returnvar" ]; then
      eval "${returnvar}=''"
    else
      printf '\n'
    fi
    return 0
  fi
  
  local result=""
  local current_line=""
  local current_length=0
  
  # Process text word by word
  while IFS= read -r line; do
    # Handle empty lines
    if [ -z "$line" ]; then
      if [ -n "$current_line" ]; then
        result="${result}${current_line}\n"
        current_line=""
        current_length=0
      fi
      result="${result}\n"
      continue
    fi
    
    # Split line into words
    set -- $line
    for word in "$@"; do
      local word_length=${#word}
      
      # If word itself is longer than columns, we need to hard break it
      if [ $word_length -gt $columns ]; then
        # First, finish current line if any
        if [ -n "$current_line" ]; then
          result="${result}${current_line}\n"
          current_line=""
          current_length=0
        fi
        
        # Break the long word
        while [ ${#word} -gt $columns ]; do
          result="${result}${word:0:$columns}\n"
          word="${word:$columns}"
        done
        
        # Handle remainder
        if [ ${#word} -gt 0 ]; then
          current_line="$word"
          current_length=${#word}
        fi
      else
        # Check if adding this word would exceed the column limit
        local space_needed=0
        if [ -n "$current_line" ]; then
          space_needed=1  # For the space before the word
        fi
        
        if [ $((current_length + space_needed + word_length)) -gt $columns ]; then
          # Start a new line
          result="${result}${current_line}\n"
          current_line="$word"
          current_length=$word_length
        else
          # Add to current line
          if [ -n "$current_line" ]; then
            current_line="${current_line} ${word}"
            current_length=$((current_length + 1 + word_length))
          else
            current_line="$word"
            current_length=$word_length
          fi
        fi
      fi
    done
  done <<EOF
$text
EOF
  
  # Add any remaining text
  if [ -n "$current_line" ]; then
    result="${result}${current_line}\n"
  fi
  
  # Remove trailing newline
  result="${result%\\n}"
  
  # Return result
  if [ -n "$returnvar" ]; then
    eval "${returnvar}=\"\$result\""
  else
    printf '%b' "$result"
  fi
}