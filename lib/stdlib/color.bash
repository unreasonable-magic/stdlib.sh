stdlib_import "color/parse"

stdlib_color() {
  local input="${| stdlib_argparser_parse "$@"; }"

  if [[ "$input" == "" ]]; then
    stdlib_argparser error/missing_arg "nothing to parse"
    return 1
  fi

  stdlib_color_parse "$input"

  pp COLOR
}
