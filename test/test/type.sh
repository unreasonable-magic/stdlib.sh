eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "test"

# Test type/is_number
assert_success stdlib_test type/is_number 42
assert_success stdlib_test type/is_number -42
assert_success stdlib_test type/is_number 3.14
assert_success stdlib_test type/is_number -3.14
assert_success stdlib_test type/is_number 0
assert_success stdlib_test type/is_number 0.0
assert_success stdlib_test type/is_number 100.
assert_failure stdlib_test type/is_number "abc"
assert_failure stdlib_test type/is_number "12abc"
assert_failure stdlib_test type/is_number ""
assert_failure stdlib_test type/is_number "1.2.3"

# Test type/is_integer
assert_success stdlib_test type/is_integer 42
assert_success stdlib_test type/is_integer -42
assert_success stdlib_test type/is_integer 0
assert_failure stdlib_test type/is_integer 3.14
assert_failure stdlib_test type/is_integer -3.14
assert_failure stdlib_test type/is_integer 0.0
assert_failure stdlib_test type/is_integer 100.
assert_failure stdlib_test type/is_integer "abc"
assert_failure stdlib_test type/is_integer ""

# Test type/is_decimal and type/is_float (aliases)
assert_success stdlib_test type/is_decimal 3.14
assert_success stdlib_test type/is_decimal -3.14
assert_success stdlib_test type/is_decimal 0.0
assert_failure stdlib_test type/is_decimal 42
assert_failure stdlib_test type/is_decimal -42
assert_failure stdlib_test type/is_decimal 100.
assert_failure stdlib_test type/is_decimal "abc"
assert_failure stdlib_test type/is_decimal ""

# Test type/is_float (alias)
assert_success stdlib_test type/is_float 3.14
assert_success stdlib_test type/is_float -3.14
assert_failure stdlib_test type/is_float 42