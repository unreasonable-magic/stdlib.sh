STDLIB_COLOR_RGB_REGEX="^[[:space:]]*rgb\([[:space:]]*([^, ]+)[[:space:]]*,?[[:space:]]*([^, ]+)[[:space:]]*,?[[:space:]]*([^, ]+)[[:space:]]*\)[[:space:]]*$"

stdlib_color_type_rgb_format() {
  printf "rgb(%0.f, %0.f, %0.f)\n" "${COLOR[1]:-0}" "${COLOR[2]:-0}" "${COLOR[3]:-0}"
}

stdlib_color_type_rgb_parse() {
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
