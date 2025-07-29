stdlib_import "argparser"
stdlib_import "color/parse"

stdlib_color_x11() {
  local input="${| stdlib_argparser_parse "$@"; }"

  if [[ "$input" == "" ]]; then
    stdlib_argparser error/missing_arg "nothing to parse"
    return 1
  fi

  if ! stdlib_color_parse "$input"; then
    stdlib_argparser error/invalid_arg "can't parse ${input@Q}"
    return 1
  fi

  # Now print the parsed RGB back to x11 format
  printf "rgb:%02x/%02x/%02x\n" "${COLOR_RGB[1]}" "${COLOR_RGB[2]}" "${COLOR_RGB[3]}"
}

STDLIB_COLOR_X11_REGEX='^[[:space:]]*rgb\:([0-9a-fA-F]{2})/([0-9a-fA-F]{2})/([0-9a-fA-F]{2})[[:space:]]*$'

stdlib_color_x11_parse() {
  if [[ "$1" =~ $STDLIB_COLOR_X11_REGEX ]]; then
    # Convert the x11 hex values into rgb numbers
    local red green blue
    local red="$((0x${BASH_REMATCH[1]}))"
    local green="$((0x${BASH_REMATCH[2]}))"
    local blue="$((0x${BASH_REMATCH[3]}))"

    declare -g -a COLOR_RGB=(
      "x11"
      "$red"
      "$green"
      "$blue"
    )

    export COLOR_RGB
    return 0
  fi

  return 1
}
