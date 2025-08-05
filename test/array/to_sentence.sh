eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "array/to_sentence"
stdlib_import "log"

# Test single item
stdout=$(stdlib_array_to_sentence "apple")
assert "$stdout" == "apple"

# Test two items
stdout=$(stdlib_array_to_sentence "apple" "banana")
assert "$stdout" == "apple and banana"

# Test three items
stdout=$(stdlib_array_to_sentence "apple" "banana" "cherry")
assert "$stdout" == "apple, banana and cherry"

# Test four items
stdout=$(stdlib_array_to_sentence "apple" "banana" "cherry" "date")
assert "$stdout" == "apple, banana, cherry and date"

# Test five items
stdout=$(stdlib_array_to_sentence "red" "green" "blue" "yellow" "purple")
assert "$stdout" == "red, green, blue, yellow and purple"

# Test stdin input with single item
stdout=$(echo "apple" | stdlib_array_to_sentence)
assert "$stdout" == "apple"

# Test stdin input with multiple items
stdout=$(printf "apple\nbanana\ncherry\n" | stdlib_array_to_sentence)
assert "$stdout" == "apple, banana and cherry"

# Test -v returnvar option
stdlib_array_to_sentence -v result "first" "second" "third"
assert "$result" == "first, second and third"

# Test empty input (should return error)
stdout=$(stdlib_array_to_sentence 2>/dev/null)
assert "$?" == "1"