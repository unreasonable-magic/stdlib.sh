#!/usr/bin/env bash
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

# Test %percentage placeholder for percentages
assert "$(stdlib_maths "100 * %percentage" "50%")" == "50"
assert "$(stdlib_maths "100 * %percentage" "50")" == "50"
assert "$(stdlib_maths "%n * %percentage" 200 "25%")" == "50"
assert "$(stdlib_maths "%n * %percentage" 200 25)" == "50"

# Test mixed placeholders
assert "$(stdlib_maths "%n * %percentage + %n" 100 25 10)" == "35"
assert "$(stdlib_maths "(%n + %n) * %percentage" 40 60 "50%")" == "50"

# Test %duration placeholder for durations
assert "$(stdlib_maths "%duration + %duration" "1h" "30m")" == "5400"
assert "$(stdlib_maths "%duration * %n" "2h" 2)" == "14400"
assert "$(stdlib_maths "%n / %duration" 7200 "1h")" == "2"
assert "$(stdlib_maths "(%duration + %duration) / %n" "1d" "12h" 2)" == "64800"

# Test "of" operator (multiplication)
assert "$(stdlib_maths "50% of 100")" == "50"
assert "$(stdlib_maths "%percentage of %n" "25%" 200)" == "50"
assert "$(stdlib_maths "%percentage of %duration" "30%" "24 hours")" == "25920"
assert "$(stdlib_maths "10% of 50")" == "5"

# Test additional variable assignments
stdlib_maths "calc_result = 5 + 5" > /tmp/stdlib_test_output.txt
assert "$(cat /tmp/stdlib_test_output.txt)" == ""
assert "$calc_result" == "10"

stdlib_maths "percent_calc = %n * %percentage" 100 "30%" > /tmp/stdlib_test_output.txt
assert "$(cat /tmp/stdlib_test_output.txt)" == ""
assert "$percent_calc" == "30"

# Test error conditions
# No format string now starts REPL mode
echo "" | stdlib_maths 2>&1 | grep -q "interactive mode"
assert "$?" == "0"

# Not enough arguments
stdlib_maths "%n + %n" 5 2>&1 | grep -q "not enough arguments"
assert "$?" == "0"

# Invalid percentage
stdlib_maths "%percentage" "abc" 2>&1 | grep -q "invalid percentage value"
assert "$?" == "0"

# Test floating point operations
assert "$(stdlib_maths "1.5 + 2.5")" == "4"
assert "$(stdlib_maths "10.5 * 2")" == "21"
assert "$(stdlib_maths "%n / %n" 7 2)" == "3.5"

# Test complex expressions
assert "$(stdlib_maths "(5 + 3) * 2 - 1")" == "15"
assert "$(stdlib_maths "100 * (50% + 25%)")" == "75"
assert "$(stdlib_maths "%n * (%percentage + %percentage)" 100 "30%" "20%")" == "50"

# Test variable assignments (should not print to stdout)
stdlib_maths "foo = 5 * 5" > /tmp/stdlib_test_output.txt
assert "$(cat /tmp/stdlib_test_output.txt)" == ""
assert "$foo" == "25"

stdlib_maths "bar = %n + %n" 10 15 > /tmp/stdlib_test_output.txt
assert "$(cat /tmp/stdlib_test_output.txt)" == ""
assert "$bar" == "25"

stdlib_maths "baz = 100 * %percentage" "30%" > /tmp/stdlib_test_output.txt
assert "$(cat /tmp/stdlib_test_output.txt)" == ""
assert "$baz" == "30"

# Clean up temp file
rm -f /tmp/stdlib_test_output.txt

# Test mathematical constants
assert "$(stdlib_maths "PI > 3.14")" == "true"
assert "$(stdlib_maths "PI < 3.15")" == "true"
assert "$(stdlib_maths "E > 2.71")" == "true"
assert "$(stdlib_maths "E < 2.72")" == "true"

# Test basic mathematical functions that work
assert "$(stdlib_maths "abs(-5)")" == "5"
assert "$(stdlib_maths "abs(5)")" == "5"
assert "$(stdlib_maths "sqrt(16)")" == "4"
assert "$(stdlib_maths "sqrt(25)")" == "5"

# Test power functions
assert "$(stdlib_maths "pow(2, 3)")" == "8"
assert "$(stdlib_maths "pow(5, 2)")" == "25"
assert "$(stdlib_maths "pow(10, 0)")" == "1"

# Test mathematical expressions with constants
assert "$(stdlib_maths "PI * 2 > 6.28")" == "true"
assert "$(stdlib_maths "E * E > 7.3")" == "true"

# Test additional mathematical functions
# Logarithmic functions
assert "$(stdlib_maths "log(E)")" == "1"
assert "$(stdlib_maths "log10(100)")" == "2"
assert "$(stdlib_maths "log2(8)")" == "3"
assert "$(stdlib_maths "log1p(0)")" == "0"

# Trigonometric functions
assert "$(stdlib_maths "sin(0)")" == "0"
assert "$(stdlib_maths "cos(0)")" == "1"
assert "$(stdlib_maths "tan(0)")" == "0"
assert "$(stdlib_maths "atan(0)")" == "0"
assert "$(stdlib_maths "asin(0)")" == "0"
assert "$(stdlib_maths "acos(1)")" == "0"

# Hyperbolic functions
assert "$(stdlib_maths "sinh(0)")" == "0"
assert "$(stdlib_maths "cosh(0)")" == "1"
assert "$(stdlib_maths "tanh(0)")" == "0"

# Exponential functions
assert "$(stdlib_maths "exp(0)")" == "1"
assert "$(stdlib_maths "exp2(3)")" == "8"
assert "$(stdlib_maths "expm1(0)")" == "0"

# Rounding functions
assert "$(stdlib_maths "floor(3.7)")" == "3"
assert "$(stdlib_maths "ceil(3.2)")" == "4"
assert "$(stdlib_maths "round(3.5)")" == "4"
assert "$(stdlib_maths "trunc(3.7)")" == "3"
assert "$(stdlib_maths "rint(3.5)")" == "4"
assert "$(stdlib_maths "nearbyint(3.5)")" == "4"

# Root functions
assert "$(stdlib_maths "cbrt(27)")" == "3"
assert "$(stdlib_maths "cbrt(8)")" == "2"

# Two-argument functions
assert "$(stdlib_maths "atan2(1, 1) > 0.78")" == "true"
assert "$(stdlib_maths "copysign(5, -1)")" == "-5"
assert "$(stdlib_maths "fdim(5, 3)")" == "2"
assert "$(stdlib_maths "fmax(5, 3)")" == "5"
assert "$(stdlib_maths "fmin(5, 3)")" == "3"
assert "$(stdlib_maths "fmod(7, 3)")" == "1"
assert "$(stdlib_maths "hypot(3, 4)")" == "5"
assert "$(stdlib_maths "remainder(7, 3)")" == "1"
assert "$(stdlib_maths "ldexp(1, 3)")" == "8"
assert "$(stdlib_maths "scalbn(2, 3)")" == "16"

# Three-argument function
assert "$(stdlib_maths "fma(2, 3, 4)")" == "10"

# Classification functions
assert "$(stdlib_maths "isfinite(5)")" == "true"
assert "$(stdlib_maths "isnormal(5)")" == "true"
assert "$(stdlib_maths "signbit(-5)")" == "true"
assert "$(stdlib_maths "signbit(5)")" == "0"

# Comparison functions
assert "$(stdlib_maths "isgreater(5, 3)")" == "true"
assert "$(stdlib_maths "isgreaterequal(5, 5)")" == "true"
assert "$(stdlib_maths "isless(3, 5)")" == "true"
assert "$(stdlib_maths "islessequal(3, 3)")" == "true"
assert "$(stdlib_maths "islessgreater(3, 5)")" == "true"

# Additional comprehensive tests for all working functions
# More trig functions
assert "$(stdlib_maths "acos(0.5) > 1.04")" == "true"
assert "$(stdlib_maths "acosh(2) > 1.31")" == "true"
assert "$(stdlib_maths "asin(0.5) > 0.52")" == "true"
assert "$(stdlib_maths "asinh(1) > 0.88")" == "true"
assert "$(stdlib_maths "atan(1) > 0.78")" == "true"
assert "$(stdlib_maths "atanh(0.5) > 0.54")" == "true"

# Error functions
assert "$(stdlib_maths "erf(1) > 0.84")" == "true"
assert "$(stdlib_maths "erfc(1) < 0.16")" == "true"

# Bessel functions
assert "$(stdlib_maths "j0(1) > 0.76")" == "true"
assert "$(stdlib_maths "j1(1) > 0.44")" == "true"
assert "$(stdlib_maths "y0(1) > 0.08")" == "true"
assert "$(stdlib_maths "y1(1) < -0.78")" == "true"
assert "$(stdlib_maths "jn(2, 1) > 0.11")" == "true"
assert "$(stdlib_maths "yn(2, 1) < -1.65")" == "true"

# Gamma functions
assert "$(stdlib_maths "lgamma(5) > 3.17")" == "true"
assert "$(stdlib_maths "tgamma(5)")" == "24"

# More logarithmic tests
assert "$(stdlib_maths "log1p(1) > 0.69")" == "true"
assert "$(stdlib_maths "logb(16)")" == "4"

# More exponential tests
assert "$(stdlib_maths "expm1(1) > 1.71")" == "true"

# Additional two-argument functions
assert "$(stdlib_maths "ldexp(2, 3)")" == "16"
assert "$(stdlib_maths "scalbn(3, 2)")" == "12"

# Test roundp function
assert "$(stdlib_maths "roundp(2.34234234, 2)")" == "2.34"
assert "$(stdlib_maths "roundp(3.14159, 3)")" == "3.142"
assert "$(stdlib_maths "roundp(10.9999, 2)")" == "11"

# Test nextafter function
assert "$(stdlib_maths "nextafter(1, 2) > 1")" == "true"
assert "$(stdlib_maths "nextafter(1, 0) < 1")" == "true"

# Test cotangent functions
assert "$(stdlib_maths "cot(PI/4) > 0.99")" == "true"
assert "$(stdlib_maths "coth(1) > 1.31")" == "true"

# Test additional classification functions
assert "$(stdlib_maths "fpclassify(5)")" == "4"
assert "$(stdlib_maths "iszero(0)")" == "true"
assert "$(stdlib_maths "iszero(1)")" == "false"
assert "$(stdlib_maths "ilogb(8)")" == "3"
assert "$(stdlib_maths "ilogb(16)")" == "4"

# Test additional constants
assert "$(stdlib_maths "GAMMA > 0.577")" == "true"
assert "$(stdlib_maths "GAMMA < 0.578")" == "true"
assert "$(stdlib_maths "DBL_MIN > 0")" == "true"
assert "$(stdlib_maths "DBL_MAX > 1e308")" == "true"

# Test special value functions (nan, inf)
assert "$(stdlib_maths "isnan(nan)")" == "true"
assert "$(stdlib_maths "isinf(inf)")" == "true"
assert "$(stdlib_maths "isinf(-inf)")" == "true"
assert "$(stdlib_maths "isfinite(inf)")" == "false"
assert "$(stdlib_maths "isfinite(5)")" == "true"
assert "$(stdlib_maths "issubnormal(DBL_MIN/2)")" == "true"
assert "$(stdlib_maths "isunordered(nan, 5)")" == "true"
assert "$(stdlib_maths "isunordered(nan, nan)")" == "true"

# Test arithmetic with special values
assert "$(stdlib_maths "isnan(0 * inf)")" == "true"
assert "$(stdlib_maths "isinf(5 + inf)")" == "true"
assert "$(stdlib_maths "isnan(sqrt(-1))")" == "true"

# Test that classification functions work with regular numbers (should return false)
assert "$(stdlib_maths "isnan(5)")" == "false"
assert "$(stdlib_maths "isinf(5)")" == "false"
assert "$(stdlib_maths "issubnormal(1.0)")" == "false"
assert "$(stdlib_maths "isunordered(5, 6)")" == "false"

# Test boolean output formatting
assert "$(stdlib_maths "5 > 3")" == "true"
assert "$(stdlib_maths "5 < 3")" == "false"
assert "$(stdlib_maths "5 == 5")" == "true"
assert "$(stdlib_maths "5 != 3")" == "true"
assert "$(stdlib_maths "5 >= 5")" == "true"
assert "$(stdlib_maths "5 <= 4")" == "false"

# Test ternary operator with numeric values
assert "$(stdlib_maths "5 > 3 ? 42 : 0")" == "42"
assert "$(stdlib_maths "5 < 3 ? 42 : 0")" == "0"
assert "$(stdlib_maths "isnan(5) ? 100 : 200")" == "200"
assert "$(stdlib_maths "isnan(nan) ? 100 : 200")" == "100"
assert "$(stdlib_maths "PI > 3 ? E : 0")" == "2.718281828459045"

# Test ternary operator with true/false (should be converted to true/false output)
assert "$(stdlib_maths "1 < 2 ? true : false")" == "true"
assert "$(stdlib_maths "1 > 2 ? true : false")" == "false"
assert "$(stdlib_maths "isnan(5) ? true : false")" == "false"
assert "$(stdlib_maths "isnan(nan) ? true : false")" == "true"

# Test exit codes for boolean expressions
# True expressions should return exit code 0
stdlib_maths "5 > 3" >/dev/null
assert "$?" == "0"
stdlib_maths "isnan(nan)" >/dev/null  
assert "$?" == "0"

# False expressions should return exit code 0 (by default)
stdlib_maths "5 < 3" >/dev/null
assert "$?" == "0"
stdlib_maths "isnan(5)" >/dev/null
assert "$?" == "0"

# Non-boolean expressions should return exit code 0
stdlib_maths "5 + 3" >/dev/null
assert "$?" == "0"
stdlib_maths "sin(0)" >/dev/null
assert "$?" == "0"

# Test REPL mode with piped input
output=$(echo -e "1 + 1\n5 > 3\nexit" | stdlib_maths | grep -v "interactive mode" | grep -v "Examples" | grep -v "^$")
expected_lines=("2" "true")
line_count=0
while IFS= read -r line; do
    if [[ -n "$line" ]]; then
        assert "$line" == "${expected_lines[$line_count]}"
        ((line_count++))
    fi
done <<< "$output"

# Test REPL variable persistence
output=$(echo -e "foo=1+2\nbar=3+4\nfoo+bar\nexit" | stdlib_maths | grep -v "interactive mode" | grep -v "Examples" | grep -v "^$")
expected_lines=("3" "7" "10")
line_count=0
while IFS= read -r line; do
    if [[ -n "$line" ]]; then
        assert "$line" == "${expected_lines[$line_count]}"
        ((line_count++))
    fi
done <<< "$output"

# Test variable validation - undefined variables should fail
stdlib_maths "undefined_var + 1" 2>/dev/null
assert "$?" == "1"

stdlib_maths "foo + bar" 2>/dev/null  
assert "$?" == "1"

stdlib_maths "sin(undefined_var)" 2>/dev/null
assert "$?" == "1"

# Test that error messages are appropriate
error_output=$(stdlib_maths "missing_var + 5" 2>&1)
assert "$error_output" =~ "undefined variable 'missing_var'"

error_output=$(stdlib_maths "log(unknown_var)" 2>&1)
assert "$error_output" =~ "undefined variable 'unknown_var'"

# Test that functions are correctly identified and not flagged as undefined variables
assert "$(stdlib_maths "sin(PI/2)")" == "1"
assert "$(stdlib_maths "log(E)")" == "1"
assert "$(stdlib_maths "sqrt(16) + cos(0)")" == "5"

# Test that constants are correctly identified
assert "$(stdlib_maths "PI > 3")" == "true"
assert "$(stdlib_maths "E + GAMMA")" == "3.295497493360578"

# Test REPL mode variable validation
repl_output=$(echo -e "foo=5\nbar=foo+10\nundefined_var+1\nexit" | stdlib_maths 2>&1)
assert "$repl_output" =~ "undefined variable 'undefined_var'"

# Test that magic _ variable works and is not flagged as undefined
repl_output=$(echo -e "1+2\nresult=_\nresult*2\nexit" | stdlib_maths | grep -v "interactive mode" | grep -v "Examples" | grep -v "^$")
expected_lines=("3" "3" "6")
line_count=0
while IFS= read -r line; do
    if [[ -n "$line" ]]; then
        assert "$line" == "${expected_lines[$line_count]}"
        ((line_count++))
    fi
done <<< "$repl_output"

# Test logical AND operator (&&)
assert "$(stdlib_maths "(5 > 3) && (2 < 4)")" == "true"
assert "$(stdlib_maths "(5 < 3) && (2 < 4)")" == "false"
assert "$(stdlib_maths "(5 > 3) && (2 > 4)")" == "false"
assert "$(stdlib_maths "(1 == 1) && (2 == 2)")" == "true"

# Test isbetween virtual function
assert "$(stdlib_maths "isbetween(5, 1, 10)")" == "true"
assert "$(stdlib_maths "isbetween(0, 1, 10)")" == "false"
assert "$(stdlib_maths "isbetween(15, 1, 10)")" == "false"
assert "$(stdlib_maths "isbetween(1, 1, 10)")" == "true"
assert "$(stdlib_maths "isbetween(10, 1, 10)")" == "true"
assert "$(stdlib_maths "isbetween(5.5, 1, 10)")" == "true"

# Test clamp virtual function
assert "$(stdlib_maths "clamp(-2, 0, 100)")" == "0"
assert "$(stdlib_maths "clamp(101, 0, 100)")" == "100"
assert "$(stdlib_maths "clamp(50, 0, 100)")" == "50"
assert "$(stdlib_maths "clamp(0, 0, 100)")" == "0"
assert "$(stdlib_maths "clamp(100, 0, 100)")" == "100"
assert "$(stdlib_maths "clamp(2.5, 1.0, 3.0)")" == "2.5"
assert "$(stdlib_maths "clamp(0.5, 1.0, 3.0)")" == "1"

# Test modulo operator %
assert "$(stdlib_maths "7 % 3")" == "1"
assert "$(stdlib_maths "10 % 4")" == "2"
assert "$(stdlib_maths "8 % 2")" == "0"
assert "$(stdlib_maths "10.5 % 3")" == "1.5"
assert "$(stdlib_maths "15 % 7")" == "1"

# Test maximum virtual function
assert "$(stdlib_maths "maximum(1, 3, 2)")" == "3"
assert "$(stdlib_maths "maximum(5, 2, 8, 1)")" == "8"
assert "$(stdlib_maths "maximum(10, 10)")" == "10"
assert "$(stdlib_maths "maximum(-5, -2, -8)")" == "-2"
assert "$(stdlib_maths "maximum(1.5, 2.3, 1.9)")" == "2.3"
assert "$(stdlib_maths "maximum(PI, E, 3)")" == "3.141592653589793"

# Test minimum virtual function
assert "$(stdlib_maths "minimum(1, 3, 2)")" == "1"
assert "$(stdlib_maths "minimum(5, 2, 8, 1)")" == "1"
assert "$(stdlib_maths "minimum(10, 10)")" == "10"
assert "$(stdlib_maths "minimum(-5, -2, -8)")" == "-8"
assert "$(stdlib_maths "minimum(1.5, 2.3, 1.9)")" == "1.5"
assert "$(stdlib_maths "minimum(PI, E, 3)")" == "2.718281828459045"

# Test exit codes for boolean expressions with new operators
# && expressions should return proper exit codes (0 by default)
stdlib_maths "(5 > 3) && (2 < 4)" >/dev/null
assert "$?" == "0"
stdlib_maths "(5 < 3) && (2 < 4)" >/dev/null
assert "$?" == "0"

# isbetween should return proper exit codes (0 by default)
stdlib_maths "isbetween(5, 1, 10)" >/dev/null
assert "$?" == "0"
stdlib_maths "isbetween(15, 1, 10)" >/dev/null
assert "$?" == "0"

# Test average virtual function
assert "$(stdlib_maths "average(1, 2, 3, 4)")" == "2.5"
assert "$(stdlib_maths "average(10, 20)")" == "15"
assert "$(stdlib_maths "average(1, 2, 3, 4, 5)")" == "3"
assert "$(stdlib_maths "average(-2, 2)")" == "0"
assert "$(stdlib_maths "average(1.5, 2.5, 3.5)")" == "2.5"
assert "$(stdlib_maths "average(PI, E, 1)")" == "2.2866248273496126"

# Test sum virtual function
assert "$(stdlib_maths "sum(1, 2, 3, 4)")" == "10"
assert "$(stdlib_maths "sum(10, 20)")" == "30"
assert "$(stdlib_maths "sum(1, 2, 3, 4, 5)")" == "15"
assert "$(stdlib_maths "sum(-2, 2)")" == "0"
assert "$(stdlib_maths "sum(1.5, 2.5, 3.5)")" == "7.5"
assert "$(stdlib_maths "sum(PI, E, 1)")" == "6.859874482048838"

# Test --dry-run option with basic virtual function compilation
echo "Testing basic virtual function compilation with --dry-run:"

# Test simple cases only to avoid infinite loops
assert "$(stdlib_maths --dry-run "isbetween(5, 1, 10)")" == "((5 >= 1) ? ((5 <= 10) ? 1 : 0) : 0)"
assert "$(stdlib_maths --dry-run "clamp(50, 0, 100)")" == "((50 < 0) ? 0 : ((50 > 100) ? 100 : 50))"
assert "$(stdlib_maths --dry-run "7 % 3")" == "fmod(7, 3)"
assert "$(stdlib_maths --dry-run "average(1, 2, 3)")" == "((1 + 2 + 3) / 3)"
assert "$(stdlib_maths --dry-run "sum(1, 2, 3)")" == "(1 + 2 + 3)"

# Test --quiet and --exit-code options
echo "Testing --quiet and --exit-code options:"

# Test that regular boolean expressions always return exit code 0
stdlib_maths "5 > 3" >/dev/null
assert "$?" == "0"
stdlib_maths "5 < 3" >/dev/null
assert "$?" == "0"

# Test --exit-code option (output still shown, but exit codes change)
assert "$(stdlib_maths --exit-code "5 > 3")" == "true"
stdlib_maths --exit-code "5 > 3" >/dev/null
assert "$?" == "0"
assert "$(stdlib_maths --exit-code "5 < 3")" == "false"
stdlib_maths --exit-code "5 < 3" >/dev/null
assert "$?" == "1"

# Test --quiet option (no output, exit codes change)
assert "$(stdlib_maths --quiet "5 > 3")" == ""
stdlib_maths --quiet "5 > 3" >/dev/null
assert "$?" == "0"
assert "$(stdlib_maths --quiet "5 < 3")" == ""
stdlib_maths --quiet "5 < 3" >/dev/null
assert "$?" == "1"

# Test -q short option
assert "$(stdlib_maths -q "10 + 5")" == ""
stdlib_maths -q "10 + 5" >/dev/null
assert "$?" == "0"

# Test that non-boolean expressions work with quiet
assert "$(stdlib_maths --quiet "2 + 2")" == ""
stdlib_maths --quiet "2 + 2" >/dev/null
assert "$?" == "0"

# Test invalid option handling
stdlib_maths --invalid-option "1 + 1" 2>/dev/null
assert "$?" == "1"

# Test --format option
echo "Testing --format option:"

# Test percentage format
assert "$(stdlib_maths --format percentage "0.25")" == "25%"
assert "$(stdlib_maths --format percentage "0.5")" == "50%"
assert "$(stdlib_maths --format percentage "1")" == "100%"
assert "$(stdlib_maths --format percentage "1/4")" == "25%"

# Test duration format
assert "$(stdlib_maths --format duration "60")" == "1 minute"
assert "$(stdlib_maths --format duration "90")" == "1 minute and 30 seconds"
assert "$(stdlib_maths --format duration "3661")" == "1 hour, 1 minute and 1 second"
assert "$(stdlib_maths --format duration "86400")" == "1 day"

# Test that boolean expressions are not formatted
assert "$(stdlib_maths --format percentage "5 > 3")" == "true"
assert "$(stdlib_maths --format duration "5 < 3")" == "false"

# Test --format with --quiet
assert "$(stdlib_maths --quiet --format percentage "0.25")" == ""
stdlib_maths --quiet --format percentage "0.25"
assert "$?" == "0"

# Test invalid format
stdlib_maths --format invalid "1 + 1" 2>&1 | grep -q "invalid format"
assert "$?" == "0"