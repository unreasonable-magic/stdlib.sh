eval "$(stdlib shellenv)"

stdlib::import "assert"
stdlib::import "string/rstrip"

declare out=""
declare stdout=""

stdout=$(rstrip "FOO")
assert "$stdout" == "FOO"

stdout=$(rstrip "    HELLO  ")
assert "$stdout" == "    HELLO"

stdout=$(echo -e "STDIN\n\n   \n\n" | rstrip)
assert "$stdout" == "STDIN"

rstrip -v out "VAR    "
assert "$out" == "VAR"
