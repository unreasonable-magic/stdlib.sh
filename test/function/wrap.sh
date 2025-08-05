eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "function/wrap"
stdlib_import "function/define"

# Create a simple test function to wrap
original_func() {
  echo "Original implementation"
  return 42
}

# Test basic wrapping
stdout="${ stdlib_function_wrap "original_func" 'echo "Before"; __original_original_func; echo "After"'; }"
assert "$stdout" == "original_func"

# Test that the wrapped function works
output="${ original_func; }"
expected=$'Before\nOriginal implementation\nAfter'
assert "$output" == "$expected"

# Test that return codes are preserved from original
__original_original_func >/dev/null
assert "$?" == "42"

# Test wrapping with --quiet flag
stdlib_function_wrap --quiet "original_func" 'echo "Quietly wrapped"; __original_original_func'
output="${ original_func; }"
expected=$'Quietly wrapped\nOriginal implementation'
assert "$output" == "$expected"

# Create another test function
math_func() {
  echo $((5 + 3))
}

# Test wrapping with parameters and original function calls
stdlib_function_wrap "math_func" '
  echo "Calculating..."
  local result=$(__original_math_func)
  echo "Result: $result"
  return 0
' >/dev/null

output="${ math_func; }"
expected=$'Calculating...\nResult: 8'
assert "$output" == "$expected"

# Test wrapping from stdin
echo 'echo "Wrapped from stdin"; __original_math_func' | stdlib_function_wrap "math_func" - >/dev/null
output="${ math_func; }"
expected=$'Wrapped from stdin\n8'
assert "$output" == "$expected"

# Test error cases - invalid function name
stdlib_function_wrap "invalid-name" "echo test" 2>/dev/null
assert "$?" == "1"

# Test error cases - non-existent function
stdlib_function_wrap "nonexistent_func" "echo test" 2>/dev/null
assert "$?" == "1"

# Test complex wrapping scenario
complex_func() {
  local name="$1"
  echo "Hello, $name!"
  return 5
}

stdlib_function_wrap "complex_func" '
  echo "--- Starting complex function ---"
  local result=$(__original_complex_func "$@")
  local exit_code=$?
  echo "Original returned: $result"
  echo "Exit code was: $exit_code"
  echo "--- Ending complex function ---"
  return $exit_code
' >/dev/null

output="${ complex_func "World"; }"
expected=$'--- Starting complex function ---\nOriginal returned: Hello, World!\nExit code was: 5\n--- Ending complex function ---'
assert "$output" == "$expected"

# Verify exit code is preserved
complex_func "Test" >/dev/null
assert "$?" == "5"

# Test that we can access the original function directly
output="${ __original_complex_func "Direct"; }"
assert "$output" == "Hello, Direct!"

# Test that stdlib_function_location returns original location from wrapped function
stdlib_import "function/location"

# Create a function and get its original location
location_test_func() {
  echo "location test"
}

original_location="${ stdlib_function_location location_test_func; }"

# Wrap the function with code that calls stdlib_function_location
stdlib_function_wrap --quiet "location_test_func" '
  local current_location="${ stdlib_function_location; }"
  echo "Location from wrapped: $current_location"
  __original_location_test_func
'

# Test that the wrapped function reports the original location
output="${ location_test_func; }"
assert "$output" =~ "Location from wrapped: .*location_test_func"
assert "$output" =~ "location test"

# Test that calling stdlib_function_location on the wrapped function returns original location
wrapped_location="${ stdlib_function_location location_test_func; }"
assert "$wrapped_location" == "$original_location"