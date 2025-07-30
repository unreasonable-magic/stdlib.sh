STDLIB_COLOR_HEX_REGEX="^[[:space:]]*#([0-9a-fA-F]{3}([0-9a-fA-F]{3})?)[[:space:]]*$"

stdlib_color_type_hex_format() {
  local red green blue

  # Round the numbers before converting to hex
  printf -v red "%0.f" "${COLOR[1]:-0}"
  printf -v green "%0.f" "${COLOR[2]:-0}"
  printf -v blue "%0.f" "${COLOR[3]:-0}"

  printf "#%02x%02x%02x\n" "$red" "$green" "$blue"
}

stdlib_color_type_hex_parse() {
  if [[ "$1" =~ $STDLIB_COLOR_HEX_REGEX ]]; then
    local hex="${BASH_REMATCH[1]}"
    local red green blue

    # When hex only has 3 charaters, then each character needs to be duplicated,
    # so #fff becomes #ffffff
    if [[ "${#hex}" == "3" ]]; then
      red="${hex:0:1}${hex:0:1}"
      green="${hex:1:1}${hex:1:1}"
      blue="${hex:2:1}${hex:2:1}"
    elif [[ "${#hex}" == "6" ]]; then
      red="${hex:0:2}"
      green="${hex:2:2}"
      blue="${hex:4:2}"
    else
      return 1
    fi

    # Convert the hex back into numbers
    red="$((0x$red))"
    green="$((0x$green))"
    blue="$((0x$blue))"

    declare -g -a COLOR=(
      "hex"
      "$red"
      "$green"
      "$blue"
    )

    export COLOR

    return 0
  fi

  return 1
}
