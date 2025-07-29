stdlib_import "argparser"
stdlib_import "color/parse"

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
stdlib_terminal_ansi_color() {
  local target="$1"
  local color="$2"

  if [[ "$target" != "foreground" && "$target" != "background" && "$target" != "underline" ]]; then
    stdlib_argparser error/invalid_arg "$target must be either background, foreground or underline"
    return 1
  fi

  # 
  if [[ $color =~ ^[0-9]+$ ]]; then
    stdlib_terminal_ansi_color_convert_256 "$target" "$color"
  elif [[ $color =~ ^[a-z_]+$ ]]; then
    stdlib_terminal_ansi_color_convert_16 "$target" "$color"
  elif stdlib_color_parse "$color"; then
    stdlib_terminal_ansi_color_convert_rgb "$target" "${COLOR_RGB[1]}" "${COLOR_RGB[2]}" "${COLOR_RGB[3]}"
  fi
}

stdlib_terminal_ansi_color_convert_rgb() {
  local target="$1"
  local red="$2"
  local green="$3"
  local blue="$4"

  local code
  if [[ "$target" == "foreground" ]]; then
    code="38;2;${red};${green};${blue}"
  elif [[ "$target" == "background" ]]; then
    code="48;2;${red};${green};${blue}"
  elif [[ "$target" == "underline" ]]; then
    code="58;2;${red};${green};${blue}"
  fi

  printf "%s\n" "$code"
}

stdlib_terminal_ansi_color_convert_256() {
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

stdlib_terminal_ansi_color_convert_16() {
  local target="$1"
  local color="$2"

  local code
  case "$color" in
  black | bright_black)
    code="0"
    ;;
  red | bright_red)
    code="1"
    ;;
  green | bright_green)
    code="2"
    ;;
  yellow | bright_yellow)
    code="3"
    ;;
  blue | bright_blue)
    code="4"
    ;;
  magenta | bright_magenta)
    code="5"
    ;;
  cyan | bright_cyan)
    code="6"
    ;;
  white | bright_white)
    code="7"
    ;;
  *)
    stdlib_argparser error/invalid_arg "not a color $color"
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
    # You can't set underline colors using the 8-16 color format, so we'll reach
    # into the 256 color range and use those instead:
    # 0-7: standard colors (as in ESC [ 30–37 m)
    # 8–15: high intensity colors (as in ESC [ 90–97 m)
    if [[ "$color" == "bright_"* ]]; then
      code="58;5;$((8 + code))"
    else
      code="58;5;${code}"
    fi
  fi

  printf "%s\n" "$code"
}
