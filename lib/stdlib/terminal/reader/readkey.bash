stdlib_import "terminal/reader"

stdlib_terminal_reader_readkey() {
  # Make sure the reader has started. This will no-op if it's been run already
  stdlib_terminal_reader_start

  local key=""

  IFS= read -r -s -n1 key </dev/tty

  # Empty strings are enter keys (aka, new lines)
  if [[ -z "$key" ]]; then
    key=$'\n'
  fi

  # IF we've received an escape, let's try to read the whole sequence
  if [[ "$key" == $'\e' ]]; then
    local sequence=""

    # Get the next character of the escape sequence
    if IFS= read -r -s -n1 -t 0.01 c2 </dev/tty; then
      sequence+="$c2"

      # If it's an CSI, then keep reading until we think we've got the whole
      # thing
      if [[ "$c2" == '[' ]]; then
        while IFS= read -r -s -n1 -t 0.01 c3 </dev/tty; do
          sequence+="$c3"

          # Check to see if we've reached the end
          if [[ "$c3" =~ [A-Za-z~u] ]]; then
            break
          fi
        done
      fi
    fi

    key="$sequence"
  fi

  # Put the key in REPLY for faster access in scripts
  REPLY="$key"
}
