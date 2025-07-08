#!/usr/bin/env bash

eval "$(stdlib shellenv)"

stdlib ui/alert <<'EOF'
# No Colors

Classic white
EOF

echo

stdlib ui/alert info <<'EOF'
# Info

Cool things to know
EOF

echo

stdlib ui/alert success <<'EOF'
# Success

You win the cheese!
EOF

echo

stdlib ui/alert warning <<'EOF'
# Warning

They mostly come out at night, mostly
EOF

echo

stdlib ui/alert error <<'EOF'
# Error

It was a funny angle
EOF

echo
echo "-------------"
echo

stdlib ui/alert error --icon "" <<'EOF'
# Custom Icon

This looks like an error but has a custom icon
EOF

echo

stdlib ui/alert success --border "☕" <<'EOF'
# Custom Border

Not sure you'd ever want to do this, but you can!
EOF

echo

stdlib ui/alert success --color "35" <<'EOF'
# Custom Color

Mmm purple
EOF
