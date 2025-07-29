STDLIB_COLOR_RGB_REGEX="^[[:space:]]*rgb\([[:space:]]*([0-9]+)[[:space:]]*,?[[:space:]]*([0-9]+)[[:space:]]*,?[[:space:]]*([0-9]+)[[:space:]]*\)[[:space:]]*$"

stdlib_color_rgb_format() {
  printf "rgb(%s, %s, %s)\n" "${COLOR[1]}" "${COLOR[2]}" "${COLOR[3]}"
}

stdlib_color_rgb_parse() {
  if [[ "$1" =~ $STDLIB_COLOR_RGB_REGEX ]]; then
    declare -g -a COLOR=(
      "rgb"
      "${BASH_REMATCH[1]}"
      "${BASH_REMATCH[2]}"
      "${BASH_REMATCH[3]}"
    )
    return 0
  fi

  return 1
}
