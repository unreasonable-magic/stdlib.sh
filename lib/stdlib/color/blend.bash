stdlib_import "color"
stdlib_import "maths"
stdlib_import "error"

stdlib_color_blend() {
  local color1="$1"
  local color2="$2"
  local percent="${3:-50}"
  
  # Remove % sign if present
  percent="${percent%\%}"
  
  # Convert percentage to decimal (0.0 to 1.0)
  local factor
  factor=$(stdlib_maths "$percent / 100")
  
  # Parse first color
  if ! stdlib_color_parse "$color1"; then
    stdlib_error "Failed to parse color1: $color1"
    return 1
  fi
  
  # Evaluate special values to actual RGB
  if ! stdlib_color_evaluate; then
    stdlib_error "Failed to evaluate color1"
    return 1
  fi
  
  # Store first color's RGB values
  local r1="${COLOR[1]}"
  local g1="${COLOR[2]}"
  local b1="${COLOR[3]}"
  
  # Parse second color
  if ! stdlib_color_parse "$color2"; then
    stdlib_error "Failed to parse color2: $color2"
    return 1
  fi
  
  # Evaluate special values to actual RGB
  if ! stdlib_color_evaluate; then
    stdlib_error "Failed to evaluate color2"
    return 1
  fi
  
  # Store second color's RGB values
  local r2="${COLOR[1]}"
  local g2="${COLOR[2]}"
  local b2="${COLOR[3]}"
  
  # Blend the colors using linear interpolation
  # result = color1 * (1 - factor) + color2 * factor
  local r_blend g_blend b_blend
  r_blend=$(stdlib_maths "$r1 * (1 - $factor) + $r2 * $factor")
  g_blend=$(stdlib_maths "$g1 * (1 - $factor) + $g2 * $factor")
  b_blend=$(stdlib_maths "$b1 * (1 - $factor) + $b2 * $factor")
  
  # Round the values
  r_blend=$(stdlib_maths "round($r_blend)")
  g_blend=$(stdlib_maths "round($g_blend)")
  b_blend=$(stdlib_maths "round($b_blend)")
  
  # Set the blended color in COLOR array for formatting
  COLOR[0]="rgb"
  COLOR[1]="$r_blend"
  COLOR[2]="$g_blend"
  COLOR[3]="$b_blend"
  
  # Output in RGB format by default
  stdlib_color_format "rgb"
}