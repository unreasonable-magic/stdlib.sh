stdlib_import "argparser"

# 8-16 colors
# \e[31m (red fg)
# \e[41m (red bg)
# \e[91m (bright/bold red fg)
# \e[101m (bright/bold red bg)
#
# 0-255 colors
# \e[38;5;1m (red fg)
# \e[48;5;1m (red bg)
#
# rgb
# \e[38;2;255;0;0m (red fg)
# \e[48;2;255;0;0m (red bg)
stdlib_terminal_color() {
  local target="$1"
  local color="$2"

  if [[ "$target" != "foreground" && "$target" != "background" && "$target" != "underline" ]]; then
    stdlib_argparser error/invalid_arg "$target must be either background, foreground or underline"
    return 1
  fi

  if [[ $color =~ ^[0-9]+$ ]] ; then
    stdlib_terminal_color_parse_256 "$target" "$color"
  else
    stdlib_terminal_color_parse_16 "$target" "$color"
  fi
}

stdlib_terminal_color_parse_256() {
  local target="$1"
  local color="$2"
  local code

  if [[ "$target" == "foreground" ]]; then
    code="38;5;${color}"
  elif [[ "$target" == "background" ]]; then
    code="48;5;${color}"
  elif [[ "$target" == "underline" ]]; then
    code="58;5;${color}"
  fi

  printf "%s\n" "$code"
}

stdlib_terminal_color_parse_16() {
  local target="$1"
  local color="$2"
  local code

  case "$color" in
    black|bright_black)
      code="0"
      ;;
    red|bright_red)
      code="1"
      ;;
    green|bright_green)
      code="2"
      ;;
    yellow|bright_yellow)
      code="3"
      ;;
    blue|bright_blue)
      code="4"
      ;;
    magenta|bright_magenta)
      code="5"
      ;;
    cyan|bright_cyan)
      code="6"
      ;;
    white|bright_white)
      code="7"
      ;;
    *)
      stdlib_argparser error/invald_arg "not a color $color"
      return 1
      ;;
  esac

  if [[ "$target" == "foreground" ]]; then
    if [[ "$color" == "bright_"* ]]; then
      code="9${code}"
    else
      code="3${code}"
    fi
  elif [[ "$target" == "background" ]]; then
    if [[ "$color" == "bright_"* ]]; then
      code="10${code}"
    else
      code="4${code}"
    fi
  elif [[ "$target" == "underline" ]]; then
    stdlib_argparser error/invald_arg "$target incompatible with 16 color parser"
    return 1
  fi

  printf "%s\n" "$code"
}
