eval "$(stdlib shellenv)"

stdlib::import "assert"
stdlib::import "string/lstrip"

declare out=""
declare stdout=""

stdout=$(lstrip "FOO")
assert "$stdout" == "FOO"

stdout=$(lstrip "    HELLO  ")
assert "$stdout" == "HELLO  "

stdout=$(echo -e "\n\n   \n\nSTDIN" | lstrip)
assert "$stdout" == "STDIN"

lstrip -v out "    VAR"
assert "$out" == "VAR"
