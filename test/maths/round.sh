eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "maths/round"

# Default precision (0 - round to integer)
stdout=$(stdlib_maths_round 3.14159)
assert "$stdout" == "3"

stdout=$(stdlib_maths_round 3.67)
assert "$stdout" == "4"

stdout=$(stdlib_maths_round 2.5)
assert "$stdout" == "3"

stdout=$(stdlib_maths_round 2.4)
assert "$stdout" == "2"

# Precision 1 (round to 1 decimal place)
stdout=$(stdlib_maths_round --precision 1 3.14159)
assert "$stdout" == "3.1"

stdout=$(stdlib_maths_round --precision 1 3.67)
assert "$stdout" == "3.7"

stdout=$(stdlib_maths_round --precision 1 2.56)
assert "$stdout" == "2.6"

stdout=$(stdlib_maths_round --precision 1 2.54)
assert "$stdout" == "2.5"

# Precision 2 (round to 2 decimal places)
stdout=$(stdlib_maths_round --precision 2 3.14159)
assert "$stdout" == "3.14"

stdout=$(stdlib_maths_round --precision 2 3.146)
assert "$stdout" == "3.15"

stdout=$(stdlib_maths_round --precision 2 123.456)
assert "$stdout" == "123.46"

# Precision 3 (round to 3 decimal places)
stdout=$(stdlib_maths_round --precision 3 3.14159)
assert "$stdout" == "3.142"

stdout=$(stdlib_maths_round --precision 3 123.4567)
assert "$stdout" == "123.457"

# Test with negative numbers
stdout=$(stdlib_maths_round -3.14159)
assert "$stdout" == "-3"

stdout=$(stdlib_maths_round --precision 2 -3.146)
assert "$stdout" == "-3.15"

stdout=$(stdlib_maths_round -2.5)
assert "$stdout" == "-3"

# Test with integers (should remain unchanged)
stdout=$(stdlib_maths_round 42)
assert "$stdout" == "42"

stdout=$(stdlib_maths_round --precision 2 42)
assert "$stdout" == "42"

# Test with trailing zeros
stdout=$(stdlib_maths_round --precision 3 3.1)
assert "$stdout" == "3.1"

stdout=$(stdlib_maths_round --precision 3 3.10)
assert "$stdout" == "3.1"

# CEILING TESTS
# Basic ceiling tests
stdout=$(stdlib_maths_round --ceil 3.14159)
assert "$stdout" == "4"

stdout=$(stdlib_maths_round --ceil 3.0)
assert "$stdout" == "3"

stdout=$(stdlib_maths_round --ceil 2.1)
assert "$stdout" == "3"

stdout=$(stdlib_maths_round --ceil 2.9)
assert "$stdout" == "3"

# Ceiling with precision
stdout=$(stdlib_maths_round --ceil --precision 1 3.14159)
assert "$stdout" == "3.2"

stdout=$(stdlib_maths_round --ceil --precision 1 3.11)
assert "$stdout" == "3.2"

stdout=$(stdlib_maths_round --ceil --precision 1 3.10)
assert "$stdout" == "3.1"

stdout=$(stdlib_maths_round --ceil --precision 2 3.14159)
assert "$stdout" == "3.15"

stdout=$(stdlib_maths_round --ceil --precision 2 3.141)
assert "$stdout" == "3.15"

stdout=$(stdlib_maths_round --ceil --precision 2 3.14)
assert "$stdout" == "3.14"

# Negative ceiling tests
stdout=$(stdlib_maths_round --ceil -3.14159)
assert "$stdout" == "-3"

stdout=$(stdlib_maths_round --ceil -3.9)
assert "$stdout" == "-3"

stdout=$(stdlib_maths_round --ceil --precision 1 -3.14159)
assert "$stdout" == "-3.1"

# FLOOR TESTS
# Basic floor tests
stdout=$(stdlib_maths_round --floor 3.14159)
assert "$stdout" == "3"

stdout=$(stdlib_maths_round --floor 3.0)
assert "$stdout" == "3"

stdout=$(stdlib_maths_round --floor 3.9)
assert "$stdout" == "3"

# Floor with precision
stdout=$(stdlib_maths_round --floor --precision 1 3.14159)
assert "$stdout" == "3.1"

stdout=$(stdlib_maths_round --floor --precision 1 3.19)
assert "$stdout" == "3.1"

stdout=$(stdlib_maths_round --floor --precision 1 3.10)
assert "$stdout" == "3.1"

stdout=$(stdlib_maths_round --floor --precision 2 3.14159)
assert "$stdout" == "3.14"

stdout=$(stdlib_maths_round --floor --precision 2 3.149)
assert "$stdout" == "3.14"

stdout=$(stdlib_maths_round --floor --precision 2 3.14)
assert "$stdout" == "3.14"

# Negative floor tests
stdout=$(stdlib_maths_round --floor -3.14159)
assert "$stdout" == "-4"

stdout=$(stdlib_maths_round --floor -3.1)
assert "$stdout" == "-4"

stdout=$(stdlib_maths_round --floor --precision 1 -3.14159)
assert "$stdout" == "-3.2"

# EDGE CASES
# Zero tests
stdout=$(stdlib_maths_round 0)
assert "$stdout" == "0"

stdout=$(stdlib_maths_round --ceil 0)
assert "$stdout" == "0"

stdout=$(stdlib_maths_round --floor 0)
assert "$stdout" == "0"

stdout=$(stdlib_maths_round --precision 2 0)
assert "$stdout" == "0"

# Large numbers
stdout=$(stdlib_maths_round 123456.789)
assert "$stdout" == "123457"

stdout=$(stdlib_maths_round --ceil 123456.789)
assert "$stdout" == "123457"

stdout=$(stdlib_maths_round --floor 123456.789)
assert "$stdout" == "123456"

# Very small decimals
stdout=$(stdlib_maths_round --precision 3 0.0001)
assert "$stdout" == "0"

stdout=$(stdlib_maths_round --ceil --precision 3 0.0001)
assert "$stdout" == "0.001"

stdout=$(stdlib_maths_round --floor --precision 3 0.0001)
assert "$stdout" == "0"
