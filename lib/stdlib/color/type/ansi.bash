STDLIB_COLOR_ANSI_REGEX="^[[:space:]]*([0-9]+);([0-9]+);([0-9]+)[[:space:]]*$"

stdlib_color_type_ansi_format() {
  printf "%s;%s;%s\n" "${COLOR[1]}" "${COLOR[2]}" "${COLOR[3]}"
}

stdlib_color_type_ansi_parse() {
  if [[ "$1" =~ $STDLIB_COLOR_ANSI_REGEX ]]; then
    declare -g -a COLOR=(
      "ansi"
      "${BASH_REMATCH[1]}"
      "${BASH_REMATCH[2]}"
      "${BASH_REMATCH[3]}"
    )
    return 0
  fi

  return 1
}
