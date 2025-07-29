stdlib_import "color/parse"

stdlib_color() {
  local input="${| stdlib_argparser_parse "$@"; }"

  if [[ "$input" == "" ]]; then
    stdlib_argparser error/missing_arg "nothing to parse"
    return 1
  fi

  if ! stdlib_color_parse "$input"; then
    return 1
  fi

  case "${COLOR[0]}" in
    rgb)
      stdlib_color_rgb_format
      ;;
    x11)
      stdlib_color_x11_format
      ;;
    hex)
      stdlib_color_hex_format
      ;;
    kv)
      stdlib_color_kv_format
      ;;
    ansi)
      stdlib_color_ansi_format
      ;;
    name)
      stdlib_color_name_format
      ;;
    *)
      stdlib_argparser error/invalid_arg "unknown format ${COLOR[0]}"
      ;;
  esac
}
