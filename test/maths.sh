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
assert "$(stdlib_maths "iszero(1)")" == "0"
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

# False expressions should return exit code 1
stdlib_maths "5 < 3" >/dev/null
assert "$?" == "1"
stdlib_maths "isnan(5)" >/dev/null
assert "$?" == "1"

# Non-boolean expressions should return exit code 0
stdlib_maths "5 + 3" >/dev/null
assert "$?" == "0"
stdlib_maths "sin(0)" >/dev/null
assert "$?" == "0"