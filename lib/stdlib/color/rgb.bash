stdlib_import "string/count"
stdlib_import "argparser"
stdlib_import "color/parse"

# Handles a few different input types:
#
#     $ stdlib color/rgb "rgb(5 5 5)"
#     $ stdlib color/rgb "rgb(5, 5, 5)"
#     $ echo "rgb(5 5 5)" | stdlib color/rgb
#     $ echo "rgb(5 5 5)" | stdlib color/rgb -
#
#     $ stdlib color/rgb 5 5 5
#
#     $ echo -e "1\n2\n3" | stdlib color/rgb - - -
#     $ echo -e "2" | stdlib color/rgb 1 - 3
#
stdlib_color_rgb() {
  local input="${| stdlib_argparser_parse "$@"; }"

  if [[ "$input" == "" ]]; then
    stdlib_argparser error/missing_arg "nothing to parse"
    return 1
  fi

  if ! stdlib_color_parse "$input"; then
    stdlib_argparser error/invalid_arg "can't parse ${input@Q}"
    return 1
  fi

  # Now we've parsed the color, let's extract the rgb values
  local -a rgb=()
  rgb[0]="${COLOR_RGB[0]:-0}"
  rgb[1]="${COLOR_RGB[1]:-0}"
  rgb[2]="${COLOR_RGB[2]:-0}"

  # Before we return the final version, make sure it looks like a valid
  if ! stdlib_color_rgb_validate_channel "red" "${rgb[0]}"; then
    return 1
  elif ! stdlib_color_rgb_validate_channel "green" "${rgb[1]}"; then
    return 1
  elif ! stdlib_color_rgb_validate_channel "blue" "${rgb[2]}"; then
    return 1
  fi

  printf "rgb(%s, %s, %s)\n" "${rgb[@]}"
}

# Matches rgb(red, green, blue) and rgb(red green blue)
STDLIB_COLOR_RGB_REGEX="^[[:space:]]*rgb\([[:space:]]*([0-9]+)[[:space:]]*,?[[:space:]]*([0-9]+)[[:space:]]*,?[[:space:]]*([0-9]+)[[:space:]]*\)[[:space:]]*$"

# Matches ansi style red;green;blue
STDLIB_COLOR_RGB_ANSI_REGEX="^[[:space:]]*([0-9]+);([0-9]+);([0-9]+)[[:space:]]*$"

stdlib_color_rgb_parse() {
  if [[ "$1" =~ $STDLIB_COLOR_RGB_REGEX || "$1" =~ $STDLIB_COLOR_RGB_ANSI_REGEX ]]; then
    declare -g -a COLOR_RGB=(
      "${BASH_REMATCH[1]}"
      "${BASH_REMATCH[2]}"
      "${BASH_REMATCH[3]}"
    )
    return 0
  fi

  return 1
}

stdlib_color_rgb_validate_channel() {
  local channel="$1"
  local value="$2"

  if [[ "$value" == "" ]]; then
    stdlib_error "$channel($value) is blank"
    return 1
  fi

  if [[ ! "$value" =~ ^-?[0-9]+$ ]]; then
    stdlib_error "$channel($value) is not a number"
    return 1
  fi

  if [[ ${value} -lt 0 || ${value} -gt 255 ]]; then
    stdlib_error "$channel($value) is out of bounds (0-255)"
    return 1
  fi

  return 0
}
