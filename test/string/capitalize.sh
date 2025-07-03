eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/capitalize"

declare out=""
declare stdout=""

stdout=$(stdlib_string_capitalize "foo")
assert "$stdout" == "Foo"

stdout=$(stdlib_string_capitalize "Foo")
assert "$stdout" == "Foo"

stdout=$(stdlib_string_capitalize $'MiXeD\nLiNeS')
assert "$stdout" == $'Mixed\nlines'

stdout=$(echo -e "STDIN\nWITH\nLINES" | stdlib_string_capitalize)
assert "$stdout" == $'Stdin\nwith\nlines'

stdlib_string_capitalize -v out "FROM a VAR"
assert "$out" == "From a var"
