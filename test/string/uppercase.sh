eval "$(stdlib shellenv)"

stdlib::import "assert"
stdlib::import "string/uppercase"

stdout=$(uppercase "foo")
stdlib::assert [ "$stdout" == "FOO" ]

stdout=$(uppercase "FOO")
stdlib::assert [ "$stdout" == "FOO" ]

stdout=$(uppercase "MiXeD\nLiNeS")
stdlib::assert [ "$stdout" == "MIXED\NLINES" ]
