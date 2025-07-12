#!/usr/bin/env bash

records="${ sqlite3 test/fixtures/northwind.db "select OrderID, ShipName, ShipCity, ShipCountry from orders limit 10" -csv; }"

echo
stdlib ui/alert info <<'EOF'
# Padding

How do these look?
EOF
echo

 echo "$records" | stdlib ui/table --renderer-arg "--style blocks" --renderer-arg "--cell-padding-left 0" --renderer-arg "--cell-padding-right 0"

echo

echo "$records" |
  stdlib ui/table --renderer-arg "--style blocks" --renderer-arg "--cell-padding-left 5" --renderer-arg "--cell-padding-right 5"

echo

stdlib ui/alert info <<'EOF'
# All Styles

There's so many to choose from!
EOF

echo

for style in $(stdlib ui/table/renderer_styles | sort); do
  echo "$style"
  echo

  echo "$records" | stdlib ui/table --renderer-arg "--style $style"
  echo
done
