stdlib_import "maths"

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
  r=$(stdlib_maths "%n / 255.0" "$red")
  g=$(stdlib_maths "%n / 255.0" "$green")
  b=$(stdlib_maths "%n / 255.0" "$blue")

  # Find the maximum and minimum RGB components
  # These are needed to calculate lightness and saturation
  local max min
  max=$(stdlib_maths "maximum(%n, %n, %n)" "$r" "$g" "$b")
  min=$(stdlib_maths "minimum(%n, %n, %n)" "$r" "$g" "$b")

  # Calculate lightness (average of max and min)
  # This represents how bright the color appears
  local lightness
  lightness=$(stdlib_maths "average(%n, %n)" "$max" "$min")

  # Calculate saturation and hue
  local delta
  delta=$(stdlib_maths "%n - %n" "$max" "$min")

  local hue saturation

  # If max equals min, the color is gray (no saturation, undefined hue)
  if stdlib_maths --quiet "%n == 0" "$delta"; then
    saturation="0"
    hue="0" # Hue is undefined for gray, but we set it to 0
  else
    # Calculate saturation based on lightness
    # The formula differs for light vs dark colors
    if stdlib_maths --quiet "%n < 0.5" "$lightness"; then
      saturation=$(stdlib_maths "%n / (%n + %n)" "$delta" "$max" "$min")
    else
      saturation=$(stdlib_maths "%n / (2.0 - %n - %n)" "$delta" "$max" "$min")
    fi

    # Calculate hue based on which RGB component is maximum
    # This determines where we are on the color wheel
    if stdlib_maths --quiet "%n == %n" "$max" "$r"; then
      # Red is dominant
      hue=$(stdlib_maths "((%n - %n) / %n) + (%n < %n ? 6.0 : 0.0)" "$g" "$b" "$delta" "$g" "$b")
    elif stdlib_maths --quiet "%n == %n" "$max" "$g"; then
      # Green is dominant
      hue=$(stdlib_maths "(%n - %n) / %n + 2.0" "$b" "$r" "$delta")
    else
      # Blue is dominant
      hue=$(stdlib_maths "(%n - %n) / %n + 4.0" "$r" "$g" "$delta")
    fi

    # Convert hue to degrees (0-360)
    hue=$(stdlib_maths "%n * 60.0" "$hue")

    # Ensure hue is positive
    hue=$(stdlib_maths "abs(%n)" "$hue")
  fi

  # Convert to percentage and round appropriately
  saturation=$(stdlib_maths "%n * 100.0" "$saturation")
  lightness=$(stdlib_maths "%n * 100.0" "$lightness")
  hue=$(stdlib_maths "%n" "$hue")

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
      grayscale=$(stdlib_maths "round(255 * (%n/100))" "$lightness")
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
    if ((lightness <= 50)); then
      chroma=$(stdlib_maths "%percentage * (2 * %percentage)" "$saturation" "$lightness")
    else
      chroma=$(stdlib_maths "%percentage * (2 - 2 * %percentage)" "$saturation" "$lightness")
    fi

    # Now calcualte how much we need of the secondary color
    local hue_sector prime
    hue_sector=$(stdlib_maths "%n / 60" "$hue")
    prime=$(stdlib_maths "%n * (1 - fabs(%n % 2 - 1))" "$chroma" "$hue_sector")

    # Now assign prime and chrome to either red, green or blue based on where we
    # are in the color wheel
    local r1=0 g1=0 b1=0

    if stdlib_maths --quiet "isbetween(%n, 0, 1)" "$hue_sector"; then
      r1="$chroma"
      g1="$prime"
      b1=0
    elif stdlib_maths --quiet "isbetween(%n, 1, 2)" "$hue_sector"; then
      r1="$prime"
      g1="$chroma"
      b1=0
    elif stdlib_maths --quiet "isbetween(%n, 2, 3)" "$hue_sector"; then
      r1=0
      g1="$chroma"
      b1="$prime"
    elif stdlib_maths --quiet "isbetween(%n, 3, 4)" "$hue_sector"; then
      r1=0
      g1="$prime"
      b1="$chroma"
    elif stdlib_maths --quiet "isbetween(%n, 4, 5)" "$hue_sector"; then
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
    minimum_rgb_value=$(stdlib_maths "%percentage - (%n / 2)" "$lightness" "$chroma")

    # Now we can mix in the minimum_rgb_value into each red, green and blue
    # value
    local red green blue
    red=$(stdlib_maths "(%n + %n) * 255" "$r1" "$minimum_rgb_value")
    green=$(stdlib_maths "(%n + %n) * 255" "$g1" "$minimum_rgb_value")
    blue=$(stdlib_maths "(%n + %n) * 255" "$b1" "$minimum_rgb_value")

    # And finally, cleanup all the values and bring them back within our 0-255
    # range (one of these numbers will be negative depending on where we sit in
    # the color wheel)
    red=$(stdlib_maths "clamp(%n, 0, 255)" "$red")
    green=$(stdlib_maths "clamp(%n, 0, 255)" "$green")
    blue=$(stdlib_maths "clamp(%n, 0, 255)" "$blue")

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
