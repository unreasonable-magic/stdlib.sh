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
