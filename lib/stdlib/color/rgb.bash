stdlib_import "string/count"
stdlib_import "argparser"

STDLIB_COLOR_RGB_REGEX="^[[:space:]]*rgb\([[:space:]]*([0-9]+)[[:space:]]*,?[[:space:]]*([0-9]+)[[:space:]]*,?[[:space:]]*([0-9]+)[[:space:]]*\)[[:space:]]*$"

stdlib_color_rgb_format() {
  # Now we've parsed the color, let's extract the rgb values
  local -a rgb=()
  rgb[0]="${COLOR[1]:-0}"
  rgb[1]="${COLOR[2]:-0}"
  rgb[2]="${COLOR[3]:-0}"

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
