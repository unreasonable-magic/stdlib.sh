eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "duration"
stdlib_import "duration/format"
stdlib_import "log"

# First test that duration function works
stdout=$(stdlib_duration "3 weeks 2 days 5 hours 4 minutes" --weeks --days --hours --minutes)
assert "$stdout" == $'3\n2\n5\n4'

# Test basic formatting
stdout=$(stdlib_duration_format "3 weeks 2 days 5 hours 4 minutes" "%w weeks, %d days, %h hours, %m minutes")
assert "$stdout" == "3 weeks, 2 days, 5 hours, 4 minutes"

# Test total values
stdout=$(stdlib_duration_format "1 hour 30 minutes" "Total minutes: %tm")
assert "$stdout" == "Total minutes: 90"

# Test %t shorthand for total seconds
stdout=$(stdlib_duration_format "2 minutes 30 seconds" "%t seconds total")
assert "$stdout" == "150 seconds total"

# Test mixed format
stdout=$(stdlib_duration_format "25 hours 45 minutes" "%d day(s) and %h:%m remaining (total: %th hours)")
assert "$stdout" == "1 day(s) and 1:45 remaining (total: 25 hours)"

# Test with variable assignment
stdlib_duration_format -v result "1 day 12 hours" "Total hours: %th"
assert "$result" == "Total hours: 36"

# Test all component values
stdout=$(stdlib_duration_format "1 year 2 months 3 weeks 4 days 5 hours 6 minutes 7 seconds" "%y years, %mo months, %w weeks, %d days, %h hours, %m minutes, %s seconds")
assert "$stdout" == "1 years, 2 months, 3 weeks, 4 days, 5 hours, 6 minutes, 7 seconds"

# Test all total values
stdout=$(stdlib_duration_format "1 week 2 days" "Years: %ty, Months: %tmo, Weeks: %tw, Days: %td, Hours: %th, Minutes: %tm, Seconds: %ts")
assert "$stdout" == "Years: 0, Months: 0, Weeks: 1, Days: 9, Hours: 216, Minutes: 12960, Seconds: 777600"

# Test empty format specifiers
stdout=$(stdlib_duration_format "30 seconds" "Time: %h:%m:%s")
assert "$stdout" == "Time: 0:0:30"

# Test complex duration with formatting
stdout=$(stdlib_duration_format "90 minutes" "%h hour(s) and %m minute(s)")
assert "$stdout" == "1 hour(s) and 30 minute(s)"

# Test format string with no specifiers
stdout=$(stdlib_duration_format "1 hour" "No format specifiers here")
assert "$stdout" == "No format specifiers here"

# Test milliseconds formatting
stdout=$(stdlib_duration_format "0.5" "%tms milliseconds")
assert "$stdout" == "500 milliseconds"

stdout=$(stdlib_duration_format "1.234" "%s.%ms seconds")
assert "$stdout" == "1.234 seconds"

# Test that milliseconds are extracted correctly
stdout=$(stdlib_duration_format "3.567" "%s seconds and %ms milliseconds")
assert "$stdout" == "3 seconds and 567 milliseconds"