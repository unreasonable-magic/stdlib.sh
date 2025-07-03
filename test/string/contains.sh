eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/contains"

stdlib_string_contains "foo" "bar"
assert "$?" == 1

stdlib_string_contains "foo" "foo"
assert "$?" == 0

stdlib_string_contains "hello world" "hell"
assert "$?" == 0

stdlib_string_contains "hello world" " world"
assert "$?" == 0

stdlib_string_contains "my file name.exe" "."
assert "$?" == 0

stdlib_string_contains "my file name" "."
assert "$?" == 1
