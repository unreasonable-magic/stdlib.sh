#!/usr/bin/env bash

eval "$(stdlib shellenv)"

my_string="this is $(whoami)"
declare -a my_array=("foo" "bar")
declare -A my_assoc_array=(
  ["foo"]="bar"
  ["another"]="toast"
)

stdlib ui/alert info <<'EOF'
# Note

The debugger can pretty print variables for inspection.
Try running the following:

  ▲ $my_string
  ▲ $my_array
  ▲ $my_assoc_array

Happy debugging!
EOF

echo

stdlib_debugger
