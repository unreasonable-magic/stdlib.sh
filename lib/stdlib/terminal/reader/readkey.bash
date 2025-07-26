stdlib_import "terminal/reader"

# ESC - sequence starting with ESC (\x1B)
# CSI - Control Sequence Introducer: sequence starting with ESC [ or CSI (\x9B)
# DCS - Device Control String: sequence starting with ESC P or DCS (\x90)
# OSC - Operating System Command: sequence starting with ESC ] or OSC (\x9D)
# ST  - either BEL (0x7 | \a) or an ESC (\x1B | \e) followed by a (\\)

stdlib_terminal_reader_readkey() {
  # Make sure the reader has started. This will no-op if it's been run already
  stdlib_terminal_reader_start

  local key=""

  IFS= read -r -s -n1 key </dev/tty

  # Empty strings are enter keys (aka, new lines)
  if [[ -z "$key" ]]; then
    REPLY=$'\n'
    return
  fi

  # IF we've received an escape, assume there's a sequence of characters we need
  # to read
  if [[ "$key" == $'\e' ]]; then
    local next_char=""

    # Get the next character of the escape sequence
    if IFS= read -r -s -n1 -t 0.01 next_char </dev/tty; then
      # Handle CSI sequences
      if [[ "$next_char" == '[' ]]; then
        local csi_sequence=""
        local csi_char=""

        while IFS= read -r -s -n1 -t 0.01 csi_char </dev/tty; do
          csi_sequence+="$csi_char"

          # Check to see if we've reached the end
          if [[ "$csi_char" =~ [A-Za-z~u] ]]; then
            break
          fi
        done

        REPLY="$csi_sequence"
        return
      fi

      # Handle OSC sequences
      if [[ "$next_char" == ']' ]]; then
        local osc_sequence=""
        local osc_char=""

        while IFS= read -r -s -n1 -t 0.01 osc_char </dev/tty; do
          # Check to see if we've reached the end
          if [[ "$osc_char" =~ $'\e' || "$osc_char" == $'\a' ]]; then
            if IFS= read -r -s -n1 -t 0.01 c4 </dev/tty; then
              if [[ "$c4" == "\\" ]]; then
                break
              else
                osc_sequence+="$c4"
              fi
            fi
          else
            osc_sequence+="$osc_char"
          fi
        done

        REPLY="$osc_sequence"
        return
      fi
    fi

    # If we couldn't do anything special with the next character just return
    # as-is
    key+="$next_char"
  fi

  # Put the key in REPLY for faster access in scripts
  REPLY="$key"
}
