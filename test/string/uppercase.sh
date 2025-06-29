eval "$(stdlib shellenv)"

stdlib::import "assert"
stdlib::import "string/uppercase"

stdout=$(uppercase "foo")
assert "$stdout" == "FOO"

stdout=$(uppercase "FOO")
assert "$stdout" == "FOO"

stdout=$(uppercase "MiXeD\nLiNeS")
assert "$stdout" == "MIXED\NLINES"

stdout=$(echo -e "STDIN\nWITH\nLINES" | uppercase)
assert "$stdout" == $'STDIN\nWITH\nLINES'

uppercase -v out "FROM a VAR"
assert "$out" == "FROM A VAR"
