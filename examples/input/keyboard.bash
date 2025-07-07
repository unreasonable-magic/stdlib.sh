#!/usr/bin/env bash

eval "$(stdlib shellenv)"

stdlib_import "input/keyboard"
stdlib_import "ui/input"

stdlib_ui_input --prompt "> "

# echo -e "\n\nentered: $buffer"
