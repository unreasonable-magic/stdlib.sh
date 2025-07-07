stdlib_import "screen/cursor"

stdlib_input_keyboard_capture() {
  local callback="${1:-__stdlib_input_keyboard_capture_default_callback}"

  # (kitty terminal) enable keyboard protocol
  printf '\e[>1u' >/dev/tty

  # https://sw.kovidgoyal.net/kitty/keyboard-protocol/#progressive-enhancement
  local disambiguate_escape_codes=1
  # local report_event_types=2
  # local report_alternate_keys=4
  # local report_all_keys_as_escape_codes=8
  # local report_associated_text=16
  # printf '\e[=%s;1u' "$((disambiguate_escape_codes + report_all_keys_as_escape_codes + report_alternate_keys + report_associated_text + report_event_types))" >/dev/tty
  # printf '\e[=%s;1u' "$((disambiguate_escape_codes + report_event_types))" >/dev/tty
  printf '\e[=%s;1u' "$((disambiguate_escape_codes))" >/dev/tty

  # Get a copy of current stty before we override it
  declare -g __stdlib_input_keyboard_prev_stty
  __stdlib_input_keyboard_prev_stty="$(stty -g)"

  # Put terminal in raw mode: no echo, no line buffering, no Ctrl+C
  stty -echo -icanon intr ''

  # Make sure what we've done is cleaned up at the end of the program
  stdlib_trapstack_add __stdlib_input_keyboard_cleanup

  # Keynames are based off this:
  # https://developer.mozilla.org/en-US/docs/Web/API/UI_Events/Keyboard_event_key_values

  while true; do
    local event_type="press"

    IFS= read -r -s -n1 char </dev/tty

    # Empty strings are enter keys
    if [[ -z "$char" ]]; then
      if "$callback" "$event_type" 'Enter'; then
        continue
      else
        break
      fi
    fi

    # Parse an escape sequence of text
    if [[ "$char" == $'\e' ]]; then
      local sequence=""

      # Read more to get the rest of the sequence
      if IFS= read -r -s -n1 -t 0.01 c2 </dev/tty; then
        sequence+="$c2"

        # If it starts CSI, try to complete it quickly
        if [[ "$c2" == '[' ]]; then
          while IFS= read -r -s -n1 -t 0.01 c3 </dev/tty; do
            sequence+="$c3"

            # Check to see if we've reached the end of the sequence
            if [[ "$c3" =~ [A-Za-z~u] ]]; then
              break
            fi
          done
        fi
      fi

      local key_code=""
      local -i mod_code

      # stdlib_debugger_vardump sequence

      if [[ "$sequence" =~ ^\[([0-9]+)?:?([0-9]+)?\;?([0-9]+)?\;?([0-9]+)?:?([0-9]+)?([ABCDEFHPQSu~])$ ]]; then
        # stdlib_debugger_vardump "BASH_REMATCH"

        if [[ "${BASH_REMATCH[6]}" == "u" ]]; then
          key_code="${BASH_REMATCH[2]:-${BASH_REMATCH[1]}}"
          mod_code="${BASH_REMATCH[3]}"
        else
          mod_code="${BASH_REMATCH[3]}"
          key_code="${BASH_REMATCH[6]}"
        fi

        if [[ "${BASH_REMATCH[5]}" == "2" ]]; then
          event_type="repeat"
        elif [[ "${BASH_REMATCH[5]}" == "3" ]]; then
          event_type="release"
        fi
      else
        stdlib_error_warning "failed to parse escape seq: $sequence"
      fi

      __stdlib_input_keyboard_code_to_key "${key_code}"
      local -a key_with_mods=("${__stdlib_input_keyboard_code_to_key}")

      if [[ "$mod_code" -gt 1 ]]; then
        mod_code=$((mod_code - 1))
        ((mod_code & 1)) && key_with_mods+=('Shift')     # 0b1
        ((mod_code & 2)) && key_with_mods+=('Alt')       # 0b10
        ((mod_code & 4)) && key_with_mods+=('Control')   # 0b100
        ((mod_code & 8)) && key_with_mods+=('Super')     # 0b1000
        ((mod_code & 16)) && key_with_mods+=('Hyper')    # 0b10000
        ((mod_code & 32)) && key_with_mods+=('Meta')     # 0b100000
        ((mod_code & 64)) && key_with_mods+=('CapsLock') # 0b1000000
        ((mod_code & 128)) && key_with_mods+=('NumLock') # 0b10000000
      fi

      if "$callback" "$event_type" "${key_with_mods[@]}"; then
        continue
      else
        break
      fi
    fi

    # Handle legacy whitespace chars
    case "$char" in
    $'\x7f' | $'\x08')
      char='Backspace'
      ;;
    $'\t')
      char='Tab'
      ;;
    esac

    if "$callback" "$event_type" "${char}"; then
      continue
    else
      break
    fi
  done

  __stdlib_input_keyboard_cleanup
}

__stdlib_input_keyboard_cleanup() {
  # (kitty terminal) disable keyboard protocol
  printf '\e[<1u' >/dev/tty

  # Restore tty to what it was before
  if [[ -z $__stdlib_input_keyboard_prev_stty ]]; then
    stty "$__stdlib_input_keyboard_prev_stty"
    unset __stdlib_input_keyboard_prev_stty
  fi

  stdlib_trapstack_remove __stdlib_input_keyboard_cleanup
}

__stdlib_input_keyboard_capture_default_callback() {
  local event="$1"
  local key="$2"
  shift 2

  local mods
  IFS="+" mods="$*"

  printf "%s\t%s\t%s\n" "$event" "${key@Q}" "$mods"
}

# I could write a function that figures this out using printf or something, but
# it's not like these things changes, so I might as well hardcode them
__stdlib_input_keyboard_code_to_key() {
  local key=""

  case "$1" in
  # Navigation keys
  A)
    key="ArrowUp"
    ;;
  D)
    key="ArrowLeft"
    ;;
  B)
    key="ArrowDown"
    ;;
  C)
    key="ArrowRight"
    ;;

  # Whitespace keys
  13)
    key="Enter"
    ;;
  9)
    key="Tab"
    ;;
  32)
    key=" "
    ;;

  # Editing keys
  127)
    key="Backspace"
    ;;

  # UI keys
  27)
    key="Escape"
    ;;

  # Symbols
  96)
    key='`'
    ;;
  45)
    key='-'
    ;;
  61)
    key='='
    ;;
  91)
    key='['
    ;;
  93)
    key=']'
    ;;
  92)
    # shellcheck disable=SC1003
    key='\'
    ;;
  59)
    key=';'
    ;;
  39)
    key="'"
    ;;
  44)
    key=","
    ;;
  46)
    key="."
    ;;
  47)
    key="/"
    ;;
  126)
    key="~"
    ;;
  33)
    key="!"
    ;;
  64)
    key="@"
    ;;
  35)
    key="#"
    ;;
  36)
    key="$"
    ;;
  37)
    key="%"
    ;;
  94)
    key="^"
    ;;
  38)
    key="&"
    ;;
  42)
    key="*"
    ;;
  40)
    key="("
    ;;
  41)
    key=")"
    ;;
  95)
    key="_"
    ;;
  43)
    key="+"
    ;;
  123)
    key="{"
    ;;
  125)
    key="}"
    ;;
  124)
    key="|"
    ;;
  58)
    key=":"
    ;;
  34)
    key='"'
    ;;
  60)
    key='<'
    ;;
  62)
    key='>'
    ;;
  63)
    key='?'
    ;;

  # Digits
  48)
    key="0"
    ;;
  49)
    key="1"
    ;;
  50)
    key="2"
    ;;
  51)
    key="3"
    ;;
  52)
    key="4"
    ;;
  53)
    key="5"
    ;;
  54)
    key="6"
    ;;
  55)
    key="7"
    ;;
  56)
    key="8"
    ;;
  57)
    key="9"
    ;;

  # Alphabet (a-z)
  97)
    key="a"
    ;;
  98)
    key="b"
    ;;
  99)
    key="c"
    ;;
  100)
    key="d"
    ;;
  101)
    key="e"
    ;;
  102)
    key="f"
    ;;
  103)
    key="g"
    ;;
  104)
    key="h"
    ;;
  105)
    key="i"
    ;;
  106)
    key="j"
    ;;
  107)
    key="k"
    ;;
  108)
    key="l"
    ;;
  109)
    key="m"
    ;;
  110)
    key="n"
    ;;
  111)
    key="o"
    ;;
  112)
    key="p"
    ;;
  113)
    key="q"
    ;;
  114)
    key="r"
    ;;
  115)
    key="s"
    ;;
  116)
    key="t"
    ;;
  117)
    key="u"
    ;;
  118)
    key="v"
    ;;
  119)
    key="w"
    ;;
  120)
    key="x"
    ;;
  121)
    key="y"
    ;;
  122)
    key="z"
    ;;

  # Alphabet (A-Z)
  65)
    key="A"
    ;;
  66)
    key="B"
    ;;
  67)
    key="C"
    ;;
  68)
    key="D"
    ;;
  69)
    key="E"
    ;;
  70)
    key="F"
    ;;
  71)
    key="G"
    ;;
  72)
    key="H"
    ;;
  73)
    key="I"
    ;;
  74)
    key="J"
    ;;
  75)
    key="K"
    ;;
  76)
    key="L"
    ;;
  77)
    key="M"
    ;;
  78)
    key="N"
    ;;
  79)
    key="O"
    ;;
  80)
    key="P"
    ;;
  81)
    key="Q"
    ;;
  82)
    key="R"
    ;;
  83)
    key="S"
    ;;
  84)
    key="T"
    ;;
  85)
    key="U"
    ;;
  86)
    key="V"
    ;;
  87)
    key="W"
    ;;
  88)
    key="X"
    ;;
  89)
    key="Y"
    ;;
  90)
    key="Z"
    ;;

  # Modifier keys
  57441)
    key="Shift"
    ;;
  57442)
    key="Control"
    ;;
  57444)
    key="Super"
    ;;
  57443)
    key="Alt"
    ;;

  # Modifier keys (right hand side)
  57447)
    key="ShiftRight"
    ;;
  57450)
    key="SuperRight"
    ;;
  57449)
    key="AltRight"
    ;;

  *)
    key="??${1@Q}??"
    ;;
  esac

  __stdlib_input_keyboard_code_to_key="${key}"
}
