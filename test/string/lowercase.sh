eval "$(stdlib shellenv)"

stdlib::import "assert"
stdlib::import "string/lowercase"

stdout=$(lowercase "FOO")
assert "$stdout" == "foo"

stdout=$(lowercase "foo")
assert "$stdout" == "foo"

stdout=$(lowercase "MiXeD\nLiNeS")
assert "$stdout" == "mixed\nlines"

stdout=$(echo -e "STDIN\nWITH\nLINES" | lowercase)
assert "$stdout" == $'stdin\nwith\nlines'

lowercase -v out "FROM a VAR"
assert "$out" == "from a var"
