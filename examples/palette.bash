#!/usr/bin/env bash

eval "$(stdlib shellenv)"

stdlib_import "terminal/palette"

# stdlib_terminal_palette_stack_push

# printf "\e[?2026h"

# printf "\e]11;#12773d\e\\"

stdlib_terminal_palette_color_set \
  background="#8b2800"  \
  foreground="#fff0a4" \
  cursor="#8b2800" \
  selection_background="#b64825" \
  selection_foreground="#12773d" \
  color0="#000000" \
  color8="#545454" \
  color1="#ba0000" \
  color9="#ba0000" \
  color2="#00ba00" \
  color10="#00ba00" \
  color3="#e6af00" \
  color11="#e6af00" \
  color4="#0000a3" \
  color12="#0000ba" \
  color5="#950062" \
  color13="#ff54ff" \
  color6="#00baba" \
  color14="#54ffff" \
  color7="#bababa" \
  color15="#ffffff" \

# printf "\x1b[H\x1b[2J"


# echo "hello"


stdlib_terminal_palette_query

# printf "\e[?2026l"

sleep 5

stdlib_terminal_palette_reset "all"

# stdlib_terminal_palette_color_reset foreground

# stdlib_terminal_palette_stack_pop
