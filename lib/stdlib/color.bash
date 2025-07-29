stdlib_import "error"
stdlib_import "color/rgb"
stdlib_import "color/hex"
stdlib_import "color/x11"
stdlib_import "color/kv"
stdlib_import "color/ansi"
stdlib_import "color/name"

stdlib_color() {
  local format_arg
  if [[ "$1" == "--format" ]]; then
    format_arg="$2"
    shift 2
  fi

  local input="${| stdlib_argparser_parse "$@"; }"

  if [[ "$input" == "" ]]; then
    stdlib_argparser error/missing_arg "nothing to parse"
    return 1
  fi

  # Reset the global COLOR variable that is populated during parsing
  unset COLOR

  # Parse the color (this will load an array into COLOR)
  if ! stdlib_color_parse "$input"; then
    return 1
  fi

  # Validate the color
  if ! stdlib_color_validate_component "red" "${COLOR[1]}"; then
    return 1
  elif ! stdlib_color_validate_component "green" "${COLOR[2]}"; then
    return 1
  elif ! stdlib_color_validate_component "blue" "${COLOR[3]}"; then
    return 1
  fi

  # Format the color (and default to the same format as passed in)
  stdlib_color_format "${format_arg:-"${COLOR[0]}"}"
}

stdlib_color_parse() {
  if stdlib_color_rgb_parse "$1"; then return; fi
  if stdlib_color_x11_parse "$1"; then return; fi
  if stdlib_color_hex_parse "$1"; then return; fi
  if stdlib_color_kv_parse "$1"; then return; fi
  if stdlib_color_ansi_parse "$1"; then return; fi
  if stdlib_color_name_parse "$1"; then return; fi

  return 1
}

stdlib_color_format() {
  case "$1" in
    rgb) stdlib_color_rgb_format ;;
    x11) stdlib_color_x11_format ;;
    hex) stdlib_color_hex_format ;;
    kv) stdlib_color_kv_format ;;
    ansi) stdlib_color_ansi_format ;;
    name) stdlib_color_name_format ;;
    *) stdlib_argparser error/invalid_arg "unknown format $1"; return 1 ;;
  esac
}

stdlib_color_validate_component() {
  local component="$1"
  local value="$2"

  # No value, nothing to validate
  if [[ "$value" == "" ]]; then
    return 0
  fi

  # Make sure it's a number
  if [[ ! "$value" =~ ^-?[0-9]+$ ]]; then
    stdlib_error "$component($value) is not a number"
    return 1
  fi

  # And that it's between 0 and 255
  if [[ ${value} -lt 0 || ${value} -gt 255 ]]; then
    stdlib_error "$component($value) is out of bounds (0-255)"
    return 1
  fi

  return 0
}
