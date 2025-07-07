#!/usr/bin/env bash

eval "$(stdlib shellenv)"

my_string="this is $(whoami)"
declare -a my_array=("foo" "bar")
declare -A my_assoc_array=(
  ["foo"]="bar"
  ["another"]="toast"
)

echo "The debugger can pretty print variables for inspection."
echo "Try running the following:"
echo
echo "  ▲ \$my_string"
echo "  ▲ \$my_array"
echo "  ▲ \$my_assoc_array"
echo

stdlib_debugger
