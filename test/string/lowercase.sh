eval "$(stdlib shellenv)"

stdlib::import "assert"
stdlib::import "string/lowercase"

stdout=$(lowercase "FOO")
stdlib::assert [ "$stdout" == "foo" ]

stdout=$(lowercase "foo")
stdlib::assert [ "$stdout" == "foo" ]

stdout=$(lowercase "MiXeD\nLiNeS")
stdlib::assert [ "$stdout" == "mixed\nlines" ]
