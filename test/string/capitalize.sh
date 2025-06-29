eval "$(stdlib shellenv)"

stdlib::import "assert"
stdlib::import "string/capitalize"

stdout=$(capitalize "foo")
assert "$stdout" == "Foo"

stdout=$(capitalize "Foo")
assert "$stdout" == "Foo"

stdout=$(capitalize $'MiXeD\nLiNeS')
assert "$stdout" == $'Mixed\nlines'

stdout=$(echo -e "STDIN\nWITH\nLINES" | capitalize)
assert "$stdout" == $'Stdin\nwith\nlines'

capitalize -v out "FROM a VAR"
assert "$out" == "From a var"
