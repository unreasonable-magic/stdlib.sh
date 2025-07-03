eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/lowercase"

declare out=""
declare stdout=""

stdout=$(stdlib_string_lowercase "FOO")
assert "$stdout" == "foo"

stdout=$(stdlib_string_lowercase "foo")
assert "$stdout" == "foo"

stdout=$(stdlib_string_lowercase "MiXeD\nLiNeS")
assert "$stdout" == "mixed\nlines"

stdout=$(echo -e "STDIN\nWITH\nLINES" | stdlib_string_lowercase)
assert "$stdout" == $'stdin\nwith\nlines'

stdlib_string_lowercase -v out "FROM a VAR"
assert "$out" == "from a var"
