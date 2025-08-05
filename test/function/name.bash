eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "function/name"

declare stdout=""
declare exit_code=0

# Test valid function names
stdout=$(stdlib_function_name "my_function")
assert "$stdout" == "my_function"
assert "$?" == "0"

stdout=$(stdlib_function_name "test123")
assert "$stdout" == "test123"
assert "$?" == "0"

stdout=$(stdlib_function_name "UPPERCASE_FUNCTION")
assert "$stdout" == "UPPERCASE_FUNCTION"
assert "$?" == "0"

stdout=$(stdlib_function_name "_underscore_start")
assert "$stdout" == "_underscore_start"
assert "$?" == "0"

stdout=$(stdlib_function_name "function_123_numbers")
assert "$stdout" == "function_123_numbers"
assert "$?" == "0"

# Test invalid function names
stdlib_function_name "func-with-dash" 2>/dev/null
assert "$?" == "1"

stdlib_function_name "func.with.dots" 2>/dev/null
assert "$?" == "1"

stdlib_function_name "func with spaces" 2>/dev/null
assert "$?" == "1"

stdlib_function_name "123startswithnumber" 2>/dev/null
assert "$?" == "1"

stdlib_function_name "func@special" 2>/dev/null
assert "$?" == "1"

stdlib_function_name "" 2>/dev/null
assert "$?" == "1"

# Test anonymous function names (surrounded by < and >)
stdout=$(stdlib_function_name "<anonymous>")
assert "$stdout" == "<anonymous>"
assert "$?" == "0"

stdout=$(stdlib_function_name "<func123>")
assert "$stdout" == "<func123>"
assert "$?" == "0"

stdout=$(stdlib_function_name "<_test_>")
assert "$stdout" == "<_test_>"
assert "$?" == "0"

# Test malformed anonymous function names
stdlib_function_name "<incomplete" 2>/dev/null
assert "$?" == "1"

stdlib_function_name "incomplete>" 2>/dev/null
assert "$?" == "1"

stdlib_function_name "<>" 2>/dev/null
assert "$?" == "1"

stdlib_function_name "<func-invalid>" 2>/dev/null
assert "$?" == "1"

# Test --quiet flag
stdout=$(stdlib_function_name --quiet "valid_function")
assert "$stdout" == ""
assert "$?" == "0"

stdout=$(stdlib_function_name --quiet "invalid-function" 2>/dev/null)
exit_code=$?
assert "$stdout" == ""
assert "$exit_code" == "1"

stdout=$(stdlib_function_name --quiet "<anonymous>")
assert "$stdout" == ""
assert "$?" == "0"

stdout=$(stdlib_function_name --quiet "<invalid" 2>/dev/null)
exit_code=$?
assert "$stdout" == ""
assert "$exit_code" == "1"

# Test edge cases
stdout=$(stdlib_function_name "a")
assert "$stdout" == "a"
assert "$?" == "0"

stdout=$(stdlib_function_name "_")
assert "$stdout" == "_"
assert "$?" == "0"

stdout=$(stdlib_function_name "__")
assert "$stdout" == "__"
assert "$?" == "0"

stdout=$(stdlib_function_name "<a>")
assert "$stdout" == "<a>"
assert "$?" == "0"