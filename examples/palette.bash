#!/usr/bin/env bash

eval "$(stdlib shellenv)"

stdlib_import "terminal/palette"

stdlib_terminal_palette_stack_push

stdlib_terminal_palette_color_set foreground=red background=yellow 
echo "hello"

sleep 3

# stdlib_terminal_palette_color_reset foreground

stdlib_terminal_palette_stack_pop
