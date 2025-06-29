eval "$(stdlib shellenv)"

stdlib::import "assert"
stdlib::import "string/contains"

stdlib::string::contains "foo" "bar"
assert "$?" == 1

stdlib::string::contains "foo" "foo"
assert "$?" == 0

stdlib::string::contains "hello world" "hell"
assert "$?" == 0

stdlib::string::contains "hello world" " world"
assert "$?" == 0

stdlib::string::contains "my file name.exe" "."
assert "$?" == 0

stdlib::string::contains "my file name" "."
assert "$?" == 1
