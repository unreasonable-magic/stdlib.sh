eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/trim"

declare out=""
declare stdout=""

stdout=$(stdlib_string_trim "FOO")
assert "$stdout" == "FOO"

stdout=$(stdlib_string_trim "    HELLO  ")
assert "$stdout" == "HELLO"

stdout=$(echo -e "\n\n\t   \t  STDIN\n\n   \n\n" | stdlib_string_trim)
assert "$stdout" == "STDIN"

stdlib_string_trim -v out "   VAR    "
assert "$out" == "VAR"
