eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "duration"
stdlib_import "log"

stdout=$(stdlib_duration "3 weeks 2 days 5 hours 4 minutes" --total-seconds)
assert "$stdout" == "2005440"

stdout=$(stdlib_duration "1 hour" --total-minutes)
assert "$stdout" == "60"

stdout=$(stdlib_duration "1 day" --total-hours)
assert "$stdout" == "24"

stdout=$(stdlib_duration "1 week" --total-days)
assert "$stdout" == "7"

stdout=$(stdlib_duration "30 seconds" --seconds)
assert "$stdout" == "30"

# Test stdin input with human-readable default
stdout=$(echo "2 hours" | stdlib_duration)
assert "$stdout" == "2 hours"

# Test stdin input with specific format
stdout=$(echo "1 day 3 hours" | stdlib_duration --total-minutes)
assert "$stdout" == "1620"

# Test human-readable format for various durations
stdout=$(stdlib_duration "1 day 2 hours 30 minutes")
assert "$stdout" == "1 day, 2 hours and 30 minutes"

stdout=$(stdlib_duration "45 seconds")
assert "$stdout" == "45 seconds"

stdout=$(stdlib_duration "1 minute")
assert "$stdout" == "1 minute"

stdout=$(stdlib_duration "0")
assert "$stdout" == "0 seconds"

stdout=$(stdlib_duration "90 seconds" --minutes --seconds)
assert "$stdout" == $'1\n30'

stdout=$(stdlib_duration "25 hours" --days --hours)
assert "$stdout" == $'1\n1'

stdout=$(stdlib_duration "3 weeks 2 days 5 hours 4 minutes" --weeks --days --hours --minutes)
assert "$stdout" == $'3\n2\n5\n4'

stdout=$(stdlib_duration "1 year 2 months 3 weeks 4 days 5 hours 6 minutes 7 seconds" --years --months --weeks --days --hours --minutes --seconds)
assert "$stdout" == $'1\n2\n3\n4\n5\n6\n7'

stdout=$(stdlib_duration "2h 30m 45s" --hours --minutes --seconds)
assert "$stdout" == $'2\n30\n45'

stdout=$(stdlib_duration "1.5 hours" --total-minutes)
assert "$stdout" == "90"

stdlib_duration -v result "1 day 12 hours" --total-hours
assert "$result" == "36"

stdout=$(stdlib_duration "366 days" --years --days)
assert "$stdout" == $'1\n1'

stdout=$(stdlib_duration "1 minute 30 seconds" --total-seconds --seconds --minutes)
assert "$stdout" == $'90\n30\n1'

# Test plain number as seconds (default behavior) - now with smart unit selection
stdout=$(stdlib_duration "60")
assert "$stdout" == "1 minute"

stdout=$(stdlib_duration "90" --minutes --seconds)
assert "$stdout" == $'1\n30'

# Test fractional seconds - now with smart unit selection
stdout=$(stdlib_duration "0.5")
assert "$stdout" == "500ms"

stdout=$(stdlib_duration "0.5" --total-milliseconds)
assert "$stdout" == "500"

stdout=$(stdlib_duration "1.5" --total-milliseconds)
assert "$stdout" == "1500"

# Test milliseconds parsing - now with unit preservation
stdout=$(stdlib_duration "500ms")
assert "$stdout" == "500ms"

stdout=$(stdlib_duration "1500 milliseconds" --total-milliseconds)
assert "$stdout" == "1500"

stdout=$(stdlib_duration "1 second 500ms" --total-milliseconds)
assert "$stdout" == "1500"

# Test more smart unit selection for plain numbers

stdout=$(stdlib_duration "120")
assert "$stdout" == "2 minutes"

stdout=$(stdlib_duration "3600")
assert "$stdout" == "1 hour"

stdout=$(stdlib_duration "86400")
assert "$stdout" == "1 day"

stdout=$(stdlib_duration "604800")
assert "$stdout" == "1 week"

stdout=$(stdlib_duration "2592000")
assert "$stdout" == "1 month"

# Test multi-component breakdown for non-round numbers
stdout=$(stdlib_duration "61")
assert "$stdout" == "1 minute and 1 second"

stdout=$(stdlib_duration "125")
assert "$stdout" == "2 minutes and 5 seconds"

stdout=$(stdlib_duration "3661")
assert "$stdout" == "1 hour, 1 minute and 1 second"

stdout=$(stdlib_duration "90061")
assert "$stdout" == "1 day, 1 hour, 1 minute and 1 second"

# Test numbers that don't convert evenly stay as seconds for edge cases
stdout=$(stdlib_duration "45")
assert "$stdout" == "45 seconds"

# Test more decimal inputs get smart sub-second conversion

stdout=$(stdlib_duration "0.001")
assert "$stdout" == "1ms"

stdout=$(stdlib_duration "0.000150")
assert "$stdout" == "150μs"

# Test decimal rounding to whole numbers
stdout=$(stdlib_duration "0.5095959595959")
assert "$stdout" == "510ms"

stdout=$(stdlib_duration "0.0001234")
assert "$stdout" == "123μs"

# Test decimal inputs that are >= 1 second get broken down into components
stdout=$(stdlib_duration "1.5")
assert "$stdout" == "1 second and 500ms"

stdout=$(stdlib_duration "2.5")
assert "$stdout" == "2 seconds and 500ms"

# Test more decimal component breakdown
stdout=$(stdlib_duration "3.25")
assert "$stdout" == "3 seconds and 250ms"

stdout=$(stdlib_duration "1.000123")
assert "$stdout" == "1 second and 123μs"

# Test unit preservation for inputs with explicit units
stdout=$(stdlib_duration "500ms")
assert "$stdout" == "500ms"

stdout=$(stdlib_duration "150μs")
assert "$stdout" == "150μs"

# Test complex duration inputs still work with traditional format
stdout=$(stdlib_duration "1 hour 30 minutes")
assert "$stdout" == "1 hour and 30 minutes"