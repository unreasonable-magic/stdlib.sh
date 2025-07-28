#!/usr/bin/env bash

eval "$(stdlib shellenv)"

stdlib_import "terminal/text"

stdlib_terminal_text underline=curly underline_color=yellow 
echo "hello"
