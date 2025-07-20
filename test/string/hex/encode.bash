eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/hex/encode"

stdout=$(stdlib_string_hex_encode "hello")
assert "$stdout" == "68656c6c6f"

stdout=$(stdlib_string_hex_encode "")
assert "$stdout" == ""

stdout=$(stdlib_string_hex_encode "ABC")
assert "$stdout" == "414243"

stdout=$(stdlib_string_hex_encode "123")
assert "$stdout" == "313233"

stdout=$(stdlib_string_hex_encode $'hello\nworld')
assert "$stdout" == "68656c6c6f0a776f726c64"

stdout=$(stdlib_string_hex_encode " ")
assert "$stdout" == "20"

stdout=$(stdlib_string_hex_encode $'\t')
assert "$stdout" == "09"
