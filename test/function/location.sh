eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "function/location"

declare out=""
declare stdout=""

# Test getting location of a simple function
simple_test() {
  echo "Hello"
  return 0
}

# Test basic function location
stdout=$(stdlib_function_location simple_test)
assert "$stdout" =~ "location.sh:[0-9]+"

current_function_location_test() {
  stdlib_function_location
}

# Should return location of current function
stdout=$(current_function_location_test)
assert "$stdout" =~ "test/function/location.sh:19"

# Test with a function from fixtures file
source test/fixtures/commented_functions.bash

# Test getting location from sourced file
stdout=$(stdlib_function_location hello_world)
assert "$stdout" =~ "commented_functions.bash:5"

stdout=$(stdlib_function_location formatted_function)
assert "$stdout" =~ "commented_functions.bash:16"

stdout=$(stdlib_function_location single_line)
assert "$stdout" =~ "commented_functions.bash:21"

# Test with non-existent function
out=$(stdlib_function_location non_existent_function 2>&1)
assert "$?" == "143"
assert "$out" =~ "couldn't find function non_existent_function"

# Test with built-in functions (should fail gracefully)
out=$(stdlib_function_location echo 2>&1)
assert "$?" == "143"
assert "$out" =~ "couldn't find function echo"

# Test with another function defined in this file
another_test_function() {
  local x=1
  local y=2
  return $((x + y))
}

stdout=$(stdlib_function_location another_test_function)
assert "$stdout" =~ "location.sh:[0-9]+"
