#!/usr/bin/env bash

eval "$(stdlib shellenv)"
stdlib_import "color/blend"

# Function to display color swatch
show_color() {
  local rgb="$1"
  # Extract RGB values from "rgb(r, g, b)" format
  local values="${rgb#rgb(}"
  values="${values%)}"
  IFS=', ' read -r r g b <<< "$values"
  
  # Show color block using ANSI 24-bit color
  printf "\033[48;2;%d;%d;%dm    \033[0m %s\n" "$r" "$g" "$b" "$rgb"
}

echo "Color Blending Examples:"
echo "========================"
echo

# Test 1: Blend red and blue at 50%
echo "Red + Blue (50%):"
result=$(stdlib_color_blend "rgb(255,0,0)" "rgb(0,0,255)" 50)
show_color "$result"
echo

# Test 2: Blend red and blue at 25% (more red)
echo "Red + Blue (25%):"
result=$(stdlib_color_blend "rgb(255,0,0)" "rgb(0,0,255)" 25)
show_color "$result"
echo

# Test 3: Blend red and blue at 75% (more blue)
echo "Red + Blue (75%):"
result=$(stdlib_color_blend "rgb(255,0,0)" "rgb(0,0,255)" 75)
show_color "$result"
echo

# Test 4: Blend white and black at 50% (should be gray)
echo "White + Black (50%):"
result=$(stdlib_color_blend "#FFFFFF" "#000000" 50)
show_color "$result"
echo

# Test 5: Blend using color names
echo "Red + Green (50%):"
result=$(stdlib_color_blend "web:red" "web:green" 50)
show_color "$result"
echo

# Test 6: Gradient from red to blue
echo "Gradient from Red to Blue:"
for percent in 0 20 40 60 80 100; do
  result=$(stdlib_color_blend "rgb(255,0,0)" "rgb(0,0,255)" $percent)
  printf "%3d%% " "$percent"
  show_color "$result"
done
echo

# Test 7: Complex colors
echo "Orange + Purple (60%):"
result=$(stdlib_color_blend "#FFA500" "#800080" 60)
show_color "$result"