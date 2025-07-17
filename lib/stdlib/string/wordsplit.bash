stdlib_string_wordsplit() {
  local input="$1"
  local -a words=()
  local word="" current_quote_char="" escape_next_char=false
  local -i pos=0

  while ((pos < ${#input})); do
    local char="${input:$pos:1}"
    ((pos++))

    if [[ $escape_next_char == true ]]; then
      if [[ $current_quote_char == '"' && $char =~ [$'\\$`"\n'] ]]; then
        word+="$char"
      elif [[ $current_quote_char == '"' ]]; then
        word+="\\$char"
      else
        word+="$char"
      fi
      escape_next_char=false

      continue
    fi

    if [[ $char == "\\" ]]; then
      escape_next_char=true

      continue
    fi

    if [[ -z $current_quote_char ]]; then
      case "$char" in
      [[:space:]])
        if [[ -n $word ]]; then
          words+=("$word")
          word=""
        fi
        ;;
      [\'\"])
        current_quote_char="$char"
        ;;
      *)
        word+="$char"
        ;;
      esac

      continue
    fi

    if [[ $char == "$current_quote_char" ]]; then
      current_quote_char=""

      continue
    fi

    word+="$char"
  done

  # Check for unterminated quotes
  if [[ -n $quote ]]; then
    echo "Error: unterminated $quote quote" >&2
    return 1
  fi

  # Add final word
  [[ -n $word ]] && words+=("$word")

  for word in "${words[@]}"; do
    printf "%s\n" "$word"
  done

  return 0
}
