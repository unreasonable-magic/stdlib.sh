stdlib_import "color/parse"

stdlib_color() {
  stdlib_color_parse "$@"

  pp COLOR_RGB
}
