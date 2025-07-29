stdlib_import "color/rgb"
stdlib_import "color/hex"
stdlib_import "color/x11"
stdlib_import "color/kv"
stdlib_import "color/ansi"

stdlib_color_parse() {
  if stdlib_color_rgb_parse "$1"; then return; fi
  if stdlib_color_hex_parse "$1"; then return; fi
  if stdlib_color_x11_parse "$1"; then return; fi
  if stdlib_color_kv_parse "$1"; then return; fi
  if stdlib_color_ansi_parse "$1"; then return; fi
  # Delay loading the color names into memory unless our other parsing attempts
  # have failed
  stdlib_import "color/name"
  if stdlib_color_name_parse "$1"; then return; fi
  return 1
}
