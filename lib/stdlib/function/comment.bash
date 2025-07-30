stdlib_import "string/dedent"

stdlib_function_comment() {
  local filepath="$1"
  local funcname="$2"

  local comment line
  while read -r line; do
    # Is the current line a comment?
    if [[ "$line" =~ ^[[:space:]]*#(.*)$ ]]; then
      comment+="${BASH_REMATCH[1]}"$'\n'
      continue
    fi

    # Once we come across a non-comment line, let's see if the next one is the
    # function we're looking for
    if [[ "$comment" != "" ]]; then
      # Skip over blank lines
      if [[ "$line" =~ ^[[:space:]]*$ ]]; then
        continue
      fi

      if [[ "$line" =~ ^stdlib_terminal_printf\(\)[[:space:]]*\{$ ]]; then
        # Huzzah, we found it!
        stdlib_string_dedent "$comment"
        return
      else
        # Comment wasn't the one we're looking for, so let's reset the buffer
        comment=""
      fi
    fi
  done < "$filepath"

  return 1
}
