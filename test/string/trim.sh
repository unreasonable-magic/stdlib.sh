eval "$(stdlib shellenv)"

stdlib::import "assert"
stdlib::import "string/trim"

declare out=""
declare stdout=""

trim -v out --leading "   VAR    "
assert "$out" == "VAR"

stdout=$(trim "FOO")
assert "$stdout" == "FOO"

stdout=$(trim "    HELLO  ")
assert "$stdout" == "HELLO"

stdout=$(echo -e "\n\n\t   \t  STDIN\n\n   \n\n" | trim)
assert "$stdout" == "STDIN"

trim -v out "   VAR    "
assert "$out" == "VAR"
