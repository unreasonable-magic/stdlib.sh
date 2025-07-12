eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/repeat"

stdout=$(stdlib_string_repeat "a" 3)
assert "$stdout" == "aaa"

stdout=$(stdlib_string_repeat "a" 0)
assert "$stdout" == ""

stdout=$(stdlib_string_repeat "ab" 4)
assert "$stdout" == "abababab"
