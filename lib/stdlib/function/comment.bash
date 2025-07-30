stdlib_import "string/dedent"
stdlib_import "test"

stdlib_function_comment() {
  local filepath="$1"
  local funcname="$2"

  # This isn't an exhaustive regex to match function names, but this is good
  # enough for now
  if [[ ! "$funcname" =~ ^[a-zA-Z0-0_]+$ ]]; then
    return 1
  fi

  # Also make sure the file exists before we try and read from it
  if ! stdlib_test file/exists "$filepath"; then
    return 1
  fi

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

      if [[ "$line" =~ ^$funcname\(\)[[:space:]]*\{$ ]]; then
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
