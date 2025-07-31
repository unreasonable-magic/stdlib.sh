#!/usr/bin/env bash

eval "$(stdlib shellenv)"

stdlib_import "color"
stdlib_import "string/underscore"

enable dsv

while IFS= read -r line; do
  if [[ "$line" == "#"* ]]; then
    continue
  fi

  dsv -d $'\t' "$line"
  stdlib_color "${DSV[1]}" > /dev/null
  printf "[\"%s\"]=\"%s\"\n" "${ stdlib_string_underscore "${DSV[0]}"; }" "${COLOR[1]};${COLOR[2]};${COLOR[3]}"
done <contrib/rgb.txt

# stdlib_import "string/dedent"
