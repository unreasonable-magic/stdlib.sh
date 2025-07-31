stdlib_import "color"
stdlib_import "terminal/text"

stdlib_color_report() {
  local rgb="${ stdlib_color "$@"; }"

  local ansi_color="${ stdlib_terminal_text foreground="$rgb"; }"
  local reset="${ stdlib_terminal_text reset; }"

  printf "\n"
  printf "%s ███████████%s RGB                 HSL\n" "$ansi_color" "$reset"
  printf "%s ███████████%s %s   %s\n" "$ansi_color" "$reset" "${ stdlib_color_type_rgb_format; }" "${ stdlib_color_type_hsl_format; }"
  printf "%s ███████████%s \n" "$ansi_color" "$reset"
  printf "%s ███████████%s Hex\n" "$ansi_color" "$reset"
  printf "%s ███████████%s %s\n" "$ansi_color" "$reset" "${ stdlib_color_type_hex_format; }"
  printf "\n"
  stdlib_terminal_text reset
}
