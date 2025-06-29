eval "$(stdlib shellenv)"

stdlib::import "assert"
stdlib::import "string/strip"

declare out=""
declare stdout=""

stdout=$(strip "FOO")
assert "$stdout" == "FOO"

stdout=$(strip "    HELLO  ")
assert "$stdout" == "HELLO"

stdout=$(echo -e "\n\n\t   \t  STDIN\n\n   \n\n" | strip)
assert "$stdout" == "STDIN"

strip -v out "   VAR    "
assert "$out" == "VAR"
