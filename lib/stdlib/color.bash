stdlib_import "error"
stdlib_import "color/type/rgb"
stdlib_import "color/type/hex"
stdlib_import "color/type/x11"
stdlib_import "color/type/kv"
stdlib_import "color/type/ansi"
stdlib_import "color/type/web"
stdlib_import "color/type/xterm"
stdlib_import "color/type/hsl"

stdlib_color() {
  local format_arg
  if [[ "$1" == "--format" ]]; then
    format_arg="$2"
    shift 2
  fi

  local input="${| stdlib_argparser_parse -- "$@"; }"

  if [[ "$input" == "" ]]; then
    stdlib_argparser error/missing_arg "nothing to parse"
    return 1
  fi

  # Parse the color (this will load an array into COLOR)
  if ! stdlib_color_parse "$input"; then
    return 1
  fi

  # Convert any special values into actual numbers (modifies the current COLOR
  # variable)
  if ! stdlib_color_evaluate; then
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
  # Reset the global COLOR variable that is populated during parsing
  unset COLOR

  if stdlib_color_type_rgb_parse "$1"; then return; fi
  if stdlib_color_type_x11_parse "$1"; then return; fi
  if stdlib_color_type_hex_parse "$1"; then return; fi
  if stdlib_color_type_kv_parse "$1"; then return; fi
  if stdlib_color_type_ansi_parse "$1"; then return; fi
  if stdlib_color_type_web_parse "$1"; then return; fi
  if stdlib_color_type_xterm_parse "$1"; then return; fi
  if stdlib_color_type_hsl_parse "$1"; then return; fi

  return 1
}

stdlib_color_evaluate() {
  if ! COLOR[1]="${ stdlib_color_evaluate_component "${COLOR[1]}"; }"; then return 1; fi
  if ! COLOR[2]="${ stdlib_color_evaluate_component "${COLOR[2]}"; }"; then return 1; fi
  if ! COLOR[3]="${ stdlib_color_evaluate_component "${COLOR[3]}"; }"; then return 1; fi
}

stdlib_color_format() {
  case "$1" in
    rgb) stdlib_color_type_rgb_format ;;
    x11) stdlib_color_type_x11_format ;;
    hex) stdlib_color_type_hex_format ;;
    kv) stdlib_color_type_kv_format ;;
    ansi) stdlib_color_type_ansi_format ;;
    web) stdlib_color_type_web_format ;;
    xterm) stdlib_color_type_xterm_format ;;
    hsl) stdlib_color_type_hsl_format ;;
    *) stdlib_argparser error/invalid_arg "unknown format $1"; return 1 ;;
  esac
}

enable fltexpr

stdlib_color_evaluate_component() {
  local component="$1"
  local min=0
  local max=255

  # Support random numbers, i.e. red=~ or red=30~40
  if [[ "$component" =~ ^(([0-9]+)(%)?)?~(([0-9]+)(%)?)?$ ]]; then
    local random_range_min="${BASH_REMATCH[2]:-"$min"}"
    local random_range_max="${BASH_REMATCH[5]:-"$max"}"

    # Are either of the values a %?
    if [[ "${BASH_REMATCH[3]}" == "%" || "${BASH_REMATCH[6]}" == "%" ]]; then
      # If they are, then they both need to be a %
      if [[ "${BASH_REMATCH[3]}" == "" || "${BASH_REMATCH[6]}" == "" ]]; then
        return 1
      fi
    fi

    fltexpr "component = random_range_min + fmod(RANDOM, (random_range_max - random_range_min + 1))"

    # Now that we've generated the random number, let's see if we need to
    # convert it back into a % so it can be expanded next
    if [[ "${BASH_REMATCH[3]}" == "%" ]]; then
      component="${component}%"
    fi
  fi

  # Support passing percentages to a componnent, i.e. red=50%
  if [[ "$component" =~ ^([0-9]+)%$ ]]; then
    fltexpr "component = max * (${BASH_REMATCH[1]}/100)"
  fi

  printf "%s\n" "$component"
}

stdlib_color_validate_component() {
  local component="$1"
  local value="$2"

  # No value, nothing to validate
  if [[ "$value" == "" ]]; then
    return 0
  fi

  # Make sure it's a number
  if [[ ! "$value" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
    stdlib_error "$component($value) is not a number"
    return 1
  fi

  # And that it's between 0 and 255 (need to use fltexpr as there might be
  # decimals in the value, which are technically valid RGB, but don't make sense
  # when it's time to display them)
  if ! fltexpr "value >= 0 ? (value <= 255 ? 1 : 0) : 0"; then
    stdlib_error "$component($value) is out of bounds (0-255)"
    return 1
  fi

  return 0
}
