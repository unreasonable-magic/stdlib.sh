eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/uppercase"

stdout=$(stdlib_string_uppercase "foo")
assert "$stdout" == "FOO"

stdout=$(stdlib_string_uppercase "FOO")
assert "$stdout" == "FOO"

stdout=$(stdlib_string_uppercase "MiXeD\nLiNeS")
assert "$stdout" == "MIXED\NLINES"

stdout=$(echo -e "STDIN\nWITH\nLINES" | stdlib_string_uppercase)
assert "$stdout" == $'STDIN\nWITH\nLINES'

stdlib_string_uppercase -v out "FROM a VAR"
assert "$out" == "FROM A VAR"
