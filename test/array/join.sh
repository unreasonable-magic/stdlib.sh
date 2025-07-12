# shellcheck disable=SC2024

eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "array/join"

declare -ga my_array=("my" "great" "array")
stdout=$(stdlib_array_join --delim "1234" -a my_array)
assert "$stdout" == "my1234great1234array"

declare -ga my_array=("hello")
stdout=$(stdlib_array_join --delim "1234" -a my_array)
assert "$stdout" == "hello"
