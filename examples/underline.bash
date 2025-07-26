#!/usr/bin/env bash

eval "$(stdlib shellenv)"

stdlib_import "terminal/underline"

stdlib_terminal_underline style=curly color=yellow 
echo "hello"
