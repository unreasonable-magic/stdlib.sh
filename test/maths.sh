eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "maths"

# Test basic arithmetic
assert "$(stdlib_maths "1 + 1")" == "2"
assert "$(stdlib_maths "10 - 5")" == "5"
assert "$(stdlib_maths "3 * 4")" == "12"
assert "$(stdlib_maths "20 / 5")" == "4"

# Test format string with %n placeholders
assert "$(stdlib_maths "%n + %n" 3 4)" == "7"
assert "$(stdlib_maths "%n * %n" 5 6)" == "30"
assert "$(stdlib_maths "%n / %n" 100 4)" == "25"
assert "$(stdlib_maths "(%n + %n) * %n" 2 3 4)" == "20"

# Test percentage support
assert "$(stdlib_maths "100 * 50%")" == "50"
assert "$(stdlib_maths "200 * 25%")" == "50"
assert "$(stdlib_maths "80 * 75%")" == "60"
assert "$(stdlib_maths "50 + 20%")" == "50.2"

# Test %p placeholder for percentages
assert "$(stdlib_maths "100 * %p" "50%")" == "50"
assert "$(stdlib_maths "100 * %p" "50")" == "50"
assert "$(stdlib_maths "%n * %p" 200 "25%")" == "50"
assert "$(stdlib_maths "%n * %p" 200 25)" == "50"

# Test mixed placeholders
assert "$(stdlib_maths "%n * %p + %n" 100 25 10)" == "35"
assert "$(stdlib_maths "(%n + %n) * %p" 40 60 "50%")" == "50"

# Test %d placeholder for durations
assert "$(stdlib_maths "%d + %d" "1h" "30m")" == "5400"
assert "$(stdlib_maths "%d * %n" "2h" 2)" == "14400"
assert "$(stdlib_maths "%n / %d" 7200 "1h")" == "2"
assert "$(stdlib_maths "(%d + %d) / %n" "1d" "12h" 2)" == "64800"

# Test "of" operator (multiplication)
assert "$(stdlib_maths "50% of 100")" == "50"
assert "$(stdlib_maths "%p of %n" "25%" 200)" == "50"
assert "$(stdlib_maths "%p of %d" "30%" "24 hours")" == "25920"
assert "$(stdlib_maths "10% of 50")" == "5"

# Test additional variable assignments
stdlib_maths "calc_result = 5 + 5" > /tmp/stdlib_test_output.txt
assert "$(cat /tmp/stdlib_test_output.txt)" == ""
assert "$calc_result" == "10"

stdlib_maths "percent_calc = %n * %p" 100 "30%" > /tmp/stdlib_test_output.txt
assert "$(cat /tmp/stdlib_test_output.txt)" == ""
assert "$percent_calc" == "30"

# Test error conditions
# No format string
stdlib_maths 2>&1 | grep -q "no format string provided"
assert "$?" == "0"

# Not enough arguments
stdlib_maths "%n + %n" 5 2>&1 | grep -q "not enough arguments"
assert "$?" == "0"

# Invalid percentage
stdlib_maths "%p" "abc" 2>&1 | grep -q "invalid percentage value"
assert "$?" == "0"

# Test floating point operations
assert "$(stdlib_maths "1.5 + 2.5")" == "4"
assert "$(stdlib_maths "10.5 * 2")" == "21"
assert "$(stdlib_maths "%n / %n" 7 2)" == "3.5"

# Test complex expressions
assert "$(stdlib_maths "(5 + 3) * 2 - 1")" == "15"
assert "$(stdlib_maths "100 * (50% + 25%)")" == "75"
assert "$(stdlib_maths "%n * (%p + %p)" 100 "30%" "20%")" == "50"

# Test variable assignments (should not print to stdout)
stdlib_maths "foo = 5 * 5" > /tmp/stdlib_test_output.txt
assert "$(cat /tmp/stdlib_test_output.txt)" == ""
assert "$foo" == "25"

stdlib_maths "bar = %n + %n" 10 15 > /tmp/stdlib_test_output.txt
assert "$(cat /tmp/stdlib_test_output.txt)" == ""
assert "$bar" == "25"

stdlib_maths "baz = 100 * %p" "30%" > /tmp/stdlib_test_output.txt
assert "$(cat /tmp/stdlib_test_output.txt)" == ""
assert "$baz" == "30"

# Clean up temp file
rm -f /tmp/stdlib_test_output.txt