enable fltexpr

STDLIB_COLOR_HSL_REGEX="^[[:space:]]*hsl\([[:space:]]*([^, ]+)[[:space:]]*,?[[:space:]]*([^, ]+%?)[[:space:]]*,?[[:space:]]*([^, ]+%?)[[:space:]]*\)[[:space:]]*$"

# stdlib_color_type_hsl
# =====================
# 
# Parser for HSL (hue, saturation, lightness) colors
#
# Background
# ----------
#
# HSL is a color space that represents colors in terms that are more intuitive 
# to humans than RGB values. It's particularly useful for color manipulation
# because it separates the color information (hue) from the intensity (lightness)
# and purity (saturation).
#
# HSL Color Space Components:
# 
# 1. HUE (H): The pure color itself, represented as a position on the color wheel
#    - Range: 0-360 degrees
#    - 0° = Red, 120° = Green, 240° = Blue
#    - Think of it as "what color is it?" (red, green, blue, yellow, etc.)
#    - The color wheel is a continuous spectrum where colors blend smoothly
#
# 2. SATURATION (S): How pure or vivid the color is
#    - Range: 0-100%
#    - 0% = Gray (no color, completely desaturated)
#    - 100% = Pure, vivid color (fully saturated)
#    - Think of it as "how colorful is it?" vs "how gray is it?"
#    - Low saturation = washed out, pastel colors
#    - High saturation = bold, vibrant colors
#
# 3. LIGHTNESS (L): How bright or dark the color is
#    - Range: 0-100%
#    - 0% = Black (no light)
#    - 50% = The "true" color (normal brightness)
#    - 100% = White (maximum light)
#    - Think of it as "how much light is mixed in?"
#    - This is different from brightness - it's about adding white or black
#
# Here's how the HSL colors play out in practice:
#
# `hsl(0, 100%, 50%)`
# : Pure red (red hue, fully saturated, normal brightness)
#
# `hsl(0, 50%, 50%)`
# : Muted red (red hue, half saturated, normal brightness)
#
# `hsl(0, 100%, 25%)`
# : Dark red (red hue, fully saturated, darker)
#
# `hsl(0, 100%, 75%)`
# : Light red/pink (red hue, fully saturated, lighter)
#
# `hsl(120, 100%, 50%)`
# : Pure green
#
# `hsl(240, 100%, 50%)`
# : Pure blue
#
stdlib_color_type_hsl_format() {
  # Get RGB values from the global COLOR array
  local red green blue
  red="${COLOR[1]:-0}"
  green="${COLOR[2]:-0}"
  blue="${COLOR[3]:-0}"

  # Convert RGB values to 0-1 range for calculations
  local r g b
  fltexpr "r = $red / 255.0"
  fltexpr "g = $green / 255.0"
  fltexpr "b = $blue / 255.0"

  # Find the maximum and minimum RGB components
  # These are needed to calculate lightness and saturation
  local max min
  fltexpr "max = (r > g) ? (r > b ? r : b) : (g > b ? g : b)"
  fltexpr "min = (r < g) ? (r < b ? r : b) : (g < b ? g : b)"

  # Calculate lightness (average of max and min)
  # This represents how bright the color appears
  local lightness
  fltexpr "lightness = (max + min) / 2.0"

  # Calculate saturation and hue
  local delta
  fltexpr "delta = max - min"

  local hue saturation

  # If max equals min, the color is gray (no saturation, undefined hue)
  if fltexpr "delta == 0"; then
    saturation="0"
    hue="0"  # Hue is undefined for gray, but we set it to 0
  else
    # Calculate saturation based on lightness
    # The formula differs for light vs dark colors
    if fltexpr "lightness < 0.5"; then
      fltexpr "saturation = delta / (max + min)"
    else
      fltexpr "saturation = delta / (2.0 - max - min)"
    fi

    # Calculate hue based on which RGB component is maximum
    # This determines where we are on the color wheel
    if fltexpr "max == r"; then
      # Red is dominant
      fltexpr "hue = ((g - b) / delta) + (g < b ? 6.0 : 0.0)"
    elif fltexpr "max == g"; then
      # Green is dominant
      fltexpr "hue = (b - r) / delta + 2.0"
    else
      # Blue is dominant
      fltexpr "hue = (r - g) / delta + 4.0"
    fi

    # Convert hue to degrees (0-360)
    fltexpr "hue = hue * 60.0"

    # Ensure hue is positive
    if fltexpr "hue < 0"; then
      fltexpr "hue = hue + 360.0"
    fi
  fi

  # Convert to percentage and round appropriately
  fltexpr "saturation = saturation * 100.0"
  fltexpr "lightness = lightness * 100.0"
  fltexpr "hue = hue"

  # Format as HSL string with proper rounding
  printf "hsl(%0.f, %0.f%%, %0.f%%)\n" "$hue" "$saturation" "$lightness"
}

stdlib_color_type_hsl_parse() {
  if [[ "$1" =~ $STDLIB_COLOR_HSL_REGEX ]]; then
    local hue="${BASH_REMATCH[1]}"
    local saturation="${BASH_REMATCH[2]}"
    local lightness="${BASH_REMATCH[3]}"

    # Remove % from both saturation and lightness so we can treat
    # them as regular integers
    saturation="${saturation/\%/}"
    lightness="${lightness/\%/}"

    # Bounds checking on all the numbers (hue is degrees, saturation + lightness
    # are percentages)
    if let "hue < 0 || hue > 360"; then
      return 1
    elif let "saturation < 0 || saturation > 100"; then
      return 1
    elif let "lightness < 0 || lightness > 100"; then
      return 1
    fi

    # If saturation is 0 (meaning, include 0% of the hue in the output), then
    # we're dealing with a grayscale color. So we can ignore hue, and take the
    # lightness value, and use that as a % between black -> white. So 0%
    # lightness is black, 100% lightnss is white, and 50% lightness is gray.
    if [[ "$saturation" == "0" ]]; then
      local grayscale
      fltexpr "grayscale = round(255 * (${lightness}/100))"
      declare -g -a COLOR=(
        "hsl"
        "${grayscale}"
        "${grayscale}"
        "${grayscale}"
      )
      return
    fi

    # Calculate how much of the the primary color we should mix into the final
    # rgb value
    #
    # Hue Range     | Primary (Chroma) | Secondary (Prime) | Unused (0)
    # --------------|------------------|-------------------|------------
    # 0° - 60°      | Red              | Green             | Blue
    # 60° - 120°    | Green            | Red               | Blue
    # 120° - 180°   | Green            | Blue              | Red
    # 180° - 240°   | Blue             | Green             | Red
    # 240° - 300°   | Blue             | Red               | Green
    # 300° - 360°   | Red              | Blue              | Green
    #
    local chroma
    if (( lightness <= 50 )); then
      fltexpr "chroma = (saturation/100) * (2 * (lightness/100))"
    else
      fltexpr "chroma = (saturation/100) * (2 - 2 * (lightness/100))"
    fi

    # Now calcualte how much we need of the secondary color
    local hue_sector prime
    fltexpr "hue_sector = hue / 60"
    fltexpr "prime = chroma * (1 - fabs(fmod(hue_sector, 2) - 1))"

    # Now assign prime and chrome to either red, green or blue based on where we
    # are in the color wheel
    local r1=0 g1=0 b1=0

    if fltexpr "hue_sector < 1"; then
      r1="$chroma"
      g1="$prime"
      b1=0
    elif fltexpr "hue_sector < 2"; then
      r1="$prime"
      g1="$chroma"
      b1=0
    elif fltexpr "hue_sector < 3"; then
      r1=0
      g1="$chroma"
      b1="$prime"
    elif fltexpr "hue_sector < 4"; then
      r1=0
      g1="$prime"
      b1="$chroma"
    elif fltexpr "hue_sector < 5"; then
      r1="$prime"
      g1=0
      b1="$chroma"
    else
      r1="$chroma"
      g1=0
      b1="$prime"
    fi

    # Figure out how much lighness we need to apply to each color, this will
    # either be a positive or a negative depending on whether or not we need to
    # make it darker or lighter
    local minimum_rgb_value
    fltexpr "minimum_rgb_value = (lightness/100) - (chroma / 2)"

    # Now we can mix in the minimum_rgb_value into each red, green and blue
    # value
    local red green blue
    fltexpr "red = (r1 + minimum_rgb_value) * 255"
    fltexpr "green = (g1 + minimum_rgb_value) * 255"
    fltexpr "blue = (b1 + minimum_rgb_value) * 255"

    # And finally, cleanup all the values and bring them back within our 0-255
    # range (one of these numbers will be negative depending on where we sit in
    # the color wheel)
    fltexpr "red = red < 0 ? 0 : (red > 255 ? 255 : red)"
    fltexpr "green = green < 0 ? 0 : (green > 255 ? 255 : green)"
    fltexpr "blue = blue < 0 ? 0 : (blue > 255 ? 255 : blue)"

    # pp chroma
    # pp prime
    # pp r1
    # pp g1
    # pp b1
    # pp minimum_rgb_value

    # Aaaand... we're done!
    declare -g -a COLOR=(
      "hsl"
      "$red"
      "$green"
      "$blue"
    )

    return 0
  fi

  return 1
}
