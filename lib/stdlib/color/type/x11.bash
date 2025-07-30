STDLIB_COLOR_X11_REGEX='^[[:space:]]*rgb\:([0-9a-fA-F]{2})/([0-9a-fA-F]{2})/([0-9a-fA-F]{2})[[:space:]]*$'

stdlib_color_type_x11_format() {
  # Round the numbers before converting to hex
  local red green blue
  printf -v red "%0.f" "${COLOR[1]:-0}"
  printf -v green "%0.f" "${COLOR[2]:-0}"
  printf -v blue "%0.f" "${COLOR[3]:-0}"

  printf "rgb:%02x/%02x/%02x\n" "$red" "$green" "$blue"
}

stdlib_color_type_x11_parse() {
  if [[ "$1" =~ $STDLIB_COLOR_X11_REGEX ]]; then
    local red green blue
    local red="$((0x${BASH_REMATCH[1]}))"
    local green="$((0x${BASH_REMATCH[2]}))"
    local blue="$((0x${BASH_REMATCH[3]}))"

    declare -g -a COLOR=(
      "x11"
      "$red"
      "$green"
      "$blue"
    )

    export COLOR
    return 0
  fi

  return 1
}
