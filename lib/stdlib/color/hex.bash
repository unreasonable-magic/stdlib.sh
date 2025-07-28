stdlib_import "argparser"
stdlib_import "color/parse"

stdlib_color_hex() {
  local input="${| stdlib_argparser_parse "$@"; }"

  if [[ "$input" == "" ]]; then
    stdlib_argparser error/missing_arg "nothing to parse"
    return 1
  fi

  if ! stdlib_color_parse "$input"; then
    stdlib_argparser error/invalid_arg "can't parse ${input@Q}"
    return 1
  fi

  # Now print the parsed RGB back to hex
  printf "#%02x%02x%02x\n" "${COLOR_RGB[0]}" "${COLOR_RGB[1]}" "${COLOR_RGB[2]}"
}

STDLIB_COLOR_HEX_REGEX="^[[:space:]]*#([0-9a-fA-F]{3}([0-9a-fA-F]{3})?)[[:space:]]*$"
STDLIB_COLOR_HEX_X11_REGEX='^[[:space:]]*rgb\:([0-9a-fA-F]{2}/[0-9a-fA-F]{2}/[0-9a-fA-F]{2})[[:space:]]*$'

stdlib_color_hex_parse() {
  if [[ "$1" =~ $STDLIB_COLOR_HEX_REGEX || "$1" =~ $STDLIB_COLOR_HEX_X11_REGEX ]]; then
    local hex="${BASH_REMATCH[1]//\//}"
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

    declare -g -a COLOR_RGB=(
      "$red"
      "$green"
      "$blue"
    )

    export COLOR_RGB

    return 0
  fi

  return 1
}
