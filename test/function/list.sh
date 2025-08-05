eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "function/list"

# Create some test functions
test_func_one() {
  echo "one"
}

test_func_two() {
  echo "two"
}

stdlib_test_function() {
  echo "stdlib test"
}

another_function() {
  echo "another"
}

# Test listing all functions (should include our test functions with locations)
all_functions="${ stdlib_function_list; }"
assert "$all_functions" =~ "test_func_one"
assert "$all_functions" =~ "test_func_two"
assert "$all_functions" =~ "stdlib_test_function"
assert "$all_functions" =~ "another_function"

# Test specific function search - should return location
output="${ stdlib_function_list "test_func_one"; }"
assert "$output" =~ "list.sh:[0-9]+:test_func_one"

# Test that non-existent function returns nothing
output="${ stdlib_function_list "nonexistent_function"; }"
assert "$output" == ""

# Test wildcard pattern - functions starting with "test_func"
output="${ stdlib_function_list "test_func*"; }"
assert "$output" =~ "test_func_one"
assert "$output" =~ "test_func_two" 
# Should return 2 locations
lines_count="${ echo "$output" | wc -l | tr -d ' '; }"
assert "$lines_count" == "2"

# Test wildcard pattern - functions starting with "stdlib"  
output="${ stdlib_function_list "stdlib*"; }"
assert "$output" =~ "stdlib_test_function"
# Should not contain test_func functions
assert ! "$output" =~ "test_func_one"

# Test wildcard pattern - functions ending with "_function"
output="${ stdlib_function_list "*_function"; }"
assert "$output" =~ "stdlib_test_function"
assert "$output" =~ "another_function"
# Should not contain test_func functions  
assert ! "$output" =~ "test_func_one"

# Test wildcard pattern - functions containing "test"
output="${ stdlib_function_list "*test*"; }"
assert "$output" =~ "test_func_one"
assert "$output" =~ "test_func_two"
assert "$output" =~ "stdlib_test_function"
# Should not contain another_function
assert ! "$output" =~ "another_function"

# Test exact match that doesn't exist
output="${ stdlib_function_list "exact_nonexistent"; }"
assert "$output" == ""

# Test pattern that matches nothing
output="${ stdlib_function_list "nomatch*"; }"
assert "$output" == ""

# Test location-formatted arguments
# First, let's get the path of the current test file for testing
current_file_path="${BASH_SOURCE[0]}"

# Test location format with wildcard function pattern - should match test functions in this file
output="${ stdlib_function_list "${current_file_path}:*:test_func*"; }"
assert "$output" =~ "test_func_one"
assert "$output" =~ "test_func_two"
# Should not match functions from other files or with different patterns
assert ! "$output" =~ "stdlib_test_function"

# Test location format with exact function match
output="${ stdlib_function_list "${current_file_path}:*:test_func_one"; }"
assert "$output" =~ "test_func_one"
assert ! "$output" =~ "test_func_two"

# Test location format with pattern that matches all functions in this file
output="${ stdlib_function_list "${current_file_path}:*:*"; }"
assert "$output" =~ "test_func_one"
assert "$output" =~ "test_func_two"
assert "$output" =~ "stdlib_test_function"
assert "$output" =~ "another_function"

# Test location format with non-existent file path - should return nothing
output="${ stdlib_function_list "/nonexistent/path.bash:*:*"; }"
assert "$output" == ""

# Test location format with pattern that matches nothing in this file
output="${ stdlib_function_list "${current_file_path}:*:nomatch*"; }"
assert "$output" == ""

# Test error case - line number is not "*"
stdlib_function_list "${current_file_path}:42:test*" 2>/dev/null
assert "$?" == "1"

# Test error case - line number is number
stdlib_function_list "${current_file_path}:123:test*" 2>/dev/null
assert "$?" == "1"

# Test error case - line number is empty
stdlib_function_list "${current_file_path}::test*" 2>/dev/null
assert "$?" == "1"