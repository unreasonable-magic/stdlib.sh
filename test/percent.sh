eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "percent"

# Test decimal to percentage conversion
assert "$(stdlib_percent 0.5)" == "50%"
assert "$(stdlib_percent 0.25)" == "25%"
assert "$(stdlib_percent 0.75)" == "75%"
assert "$(stdlib_percent 0.1)" == "10%"
assert "$(stdlib_percent 0.01)" == "1%"
assert "$(stdlib_percent 0.001)" == "0.1%"
assert "$(stdlib_percent 0)" == "0%"

# Test whole numbers (now treated as decimals)
assert "$(stdlib_percent 1)" == "100%"
assert "$(stdlib_percent 2)" == "200%"
assert "$(stdlib_percent 50)" == "5000%"
assert "$(stdlib_percent 100)" == "10000%"
assert "$(stdlib_percent 0.3)" == "30%"

# Test numbers already with % sign
assert "$(stdlib_percent "50%")" == "50%"
assert "$(stdlib_percent "100%")" == "100%"
assert "$(stdlib_percent "0.5%")" == "0.5%"

# Test stdin input
assert "$(echo "0.5" | stdlib_percent)" == "50%"
assert "$(echo "0.75" | stdlib_percent)" == "75%"
assert "$(echo "1" | stdlib_percent)" == "100%"
assert "$(echo "100%" | stdlib_percent)" == "100%"

# Test -v option
stdlib_percent -v result 0.5
assert "$result" == "50%"

stdlib_percent -v result 0.75
assert "$result" == "75%"

stdlib_percent -v result 1
assert "$result" == "100%"

# Test fractional percentages
assert "$(stdlib_percent 0.125)" == "12.5%"
assert "$(stdlib_percent 0.333)" == "33.3%"
assert "$(stdlib_percent 0.6666)" == "66.66%"

# Test edge cases
assert "$(stdlib_percent 1.5)" == "150%"
assert "$(stdlib_percent 10.5)" == "1050%"
assert "$(stdlib_percent 0.155)" == "15.5%"
assert "$(stdlib_percent 0.0025)" == "0.25%"

# Note: stdlib_percent always treats numbers as decimals
# So 25 becomes 2500%, not 25%
# This is consistent: 0.25 = 25%, 1 = 100%, 25 = 2500%