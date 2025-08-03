eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "color"

# Test RGB parsing
assert "$(stdlib_color "rgb(255, 0, 0)")" == "rgb(255, 0, 0)"
assert "$(stdlib_color "rgb(128, 128, 128)")" == "rgb(128, 128, 128)"
assert "$(stdlib_color --format hex "rgb(255, 0, 0)")" == "#ff0000"

# Test with spaces and variations
stdlib_color "rgb( 255 , 0 , 0 )"
assert "$?" == "0"
stdlib_color "rgb(255,0,0)"
assert "$?" == "0"

# Test Hex parsing
assert "$(stdlib_color "#ff0000")" == "#ff0000"
assert "$(stdlib_color "#f00")" == "#ff0000"
assert "$(stdlib_color --format rgb "#ff0000")" == "rgb(255, 0, 0)"
assert "$(stdlib_color --format rgb "#fff")" == "rgb(255, 255, 255)"

# Test mixed case
stdlib_color "#FF0000"
assert "$?" == "0"
stdlib_color "#fF0000"
assert "$?" == "0"

# Test HSL parsing
assert "$(stdlib_color "hsl(0, 100%, 50%)")" == "hsl(0, 100%, 50%)"
assert "$(stdlib_color --format rgb "hsl(0, 100%, 50%)")" == "rgb(255, 0, 0)"

# Test grayscale (0% saturation)
assert "$(stdlib_color "hsl(0, 0%, 50%)")" == "hsl(0, 0%, 50%)"
assert "$(stdlib_color --format rgb "hsl(0, 0%, 50%)")" == "rgb(128, 128, 128)"

# Test different hues
assert "$(stdlib_color --format rgb "hsl(120, 100%, 50%)")" == "rgb(0, 255, 0)"
assert "$(stdlib_color --format rgb "hsl(240, 100%, 50%)")" == "rgb(0, 0, 255)"

# Test X11 parsing
assert "$(stdlib_color "rgb:ff/00/00")" == "rgb:ff/00/00"
assert "$(stdlib_color --format rgb "rgb:ff/00/00")" == "rgb(255, 0, 0)"

# Test KV parsing
assert "$(stdlib_color "red=255 green=0 blue=0")" == "red=255 green=0 blue=0"
assert "$(stdlib_color --format rgb "red=255 green=0 blue=0")" == "rgb(255, 0, 0)"

# Test different order
stdlib_color "green=128 red=255 blue=0"
assert "$?" == "0"

# Test ANSI parsing
assert "$(stdlib_color "2;255;0;0")" == "2;255;0;0"
assert "$(stdlib_color --format rgb "2;255;0;0")" == "rgb(255, 0, 0)"

# Test Web parsing
assert "$(stdlib_color "web:red")" == "web:red"
assert "$(stdlib_color --format rgb "web:red")" == "rgb(255, 0, 0)"

# Test different web colors
stdlib_color "web:blue"
assert "$?" == "0"
stdlib_color "web:green"
assert "$?" == "0"
stdlib_color "web:white"
assert "$?" == "0"
stdlib_color "web:black"
assert "$?" == "0"

# Test case sensitivity
stdlib_color "web:Red"
assert "$?" == "0"
stdlib_color "web:BLUE"
assert "$?" == "0"

# Test XTerm parsing
stdlib_color "xterm:red"
assert "$?" == "0"
stdlib_color "xterm:blue"
assert "$?" == "0"
stdlib_color "xterm:1"
assert "$?" == "0"
stdlib_color "xterm:196"
assert "$?" == "0"

# Test color evaluation with percentages
assert "$(stdlib_color "rgb(50%, 0, 0)")" == "rgb(128, 0, 0)"

# Test random range evaluation (results will vary, so just test success)
stdlib_color "rgb(~, 0, 0)"
assert "$?" == "0"
stdlib_color "rgb(100~200, 0, 0)"
assert "$?" == "0"
stdlib_color "rgb(50%~75%, 0, 0)"
assert "$?" == "0"

# Test format conversions
assert "$(stdlib_color --format rgb "#ff0000")" == "rgb(255, 0, 0)"
assert "$(stdlib_color --format hex "rgb(255, 0, 0)")" == "#ff0000"
assert "$(stdlib_color --format x11 "rgb(255, 0, 0)")" == "rgb:ff/00/00"
assert "$(stdlib_color --format kv "rgb(255, 0, 0)")" == "red=255 green=0 blue=0"
assert "$(stdlib_color --format ansi "rgb(255, 0, 0)")" == "2;255;0;0"

# Test validation errors
stdlib_color "rgb(256, 0, 0)"
assert "$?" == "1"
stdlib_color "rgb(-1, 0, 0)"
assert "$?" == "1"
stdlib_color "rgb(abc, 0, 0)"
assert "$?" == "1"
stdlib_color "hsl(361, 100%, 50%)"
assert "$?" == "1"
stdlib_color "hsl(0, 101%, 50%)"
assert "$?" == "1"
stdlib_color "hsl(0, 100%, 101%)"
assert "$?" == "1"
stdlib_color "invalid_color_format"
assert "$?" == "1"

# Test edge cases
assert "$(stdlib_color "rgb(0, 0, 0)")" == "rgb(0, 0, 0)"
assert "$(stdlib_color "rgb(255, 255, 255)")" == "rgb(255, 255, 255)"
assert "$(stdlib_color --format hex "rgb(0, 0, 0)")" == "#000000"
assert "$(stdlib_color --format hex "rgb(255, 255, 255)")" == "#ffffff"

# Test decimal values (should be rounded)
assert "$(stdlib_color "rgb(127.6, 0, 0)")" == "rgb(128, 0, 0)"

# Test HSL special cases - pure hues at 100% saturation, 50% lightness
assert "$(stdlib_color --format rgb "hsl(0, 100%, 50%)")" == "rgb(255, 0, 0)"
assert "$(stdlib_color --format rgb "hsl(60, 100%, 50%)")" == "rgb(255, 255, 0)"
assert "$(stdlib_color --format rgb "hsl(120, 100%, 50%)")" == "rgb(0, 255, 0)"
assert "$(stdlib_color --format rgb "hsl(180, 100%, 50%)")" == "rgb(0, 255, 255)"
assert "$(stdlib_color --format rgb "hsl(240, 100%, 50%)")" == "rgb(0, 0, 255)"
assert "$(stdlib_color --format rgb "hsl(300, 100%, 50%)")" == "rgb(255, 0, 255)"

# Test lightness variations
assert "$(stdlib_color --format rgb "hsl(0, 100%, 0%)")" == "rgb(0, 0, 0)"
assert "$(stdlib_color --format rgb "hsl(0, 100%, 100%)")" == "rgb(255, 255, 255)"
assert "$(stdlib_color --format rgb "hsl(0, 100%, 25%)")" == "rgb(128, 0, 0)"
assert "$(stdlib_color --format rgb "hsl(0, 100%, 75%)")" == "rgb(255, 128, 128)"