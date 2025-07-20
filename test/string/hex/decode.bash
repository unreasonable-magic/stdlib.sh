eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/hex/encode"
stdlib_import "string/hex/decode"

stdout=$(stdlib_string_hex_decode "68656c6c6f")
assert "$stdout" == "hello"

stdout=$(stdlib_string_hex_decode "$(stdlib_string_hex_encode 'hello')")
assert "$stdout" == "hello"

stdout=$(stdlib_string_hex_decode "")
assert "$stdout" == ""

stdout=$(stdlib_string_hex_decode "$(stdlib_string_hex_encode '')")
assert "$stdout" == ""

stdout=$(stdlib_string_hex_decode "414243")
assert "$stdout" == "ABC"

stdout=$(stdlib_string_hex_decode "$(stdlib_string_hex_encode 'ABC')")
assert "$stdout" == "ABC"

stdout=$(stdlib_string_hex_decode "313233")
assert "$stdout" == "123"

stdout=$(stdlib_string_hex_decode "68656c6c6f0a776f726c64")
assert "$stdout" == $'hello\nworld'

stdout=$(stdlib_string_hex_decode "20")
assert "$stdout" == " "

stdout=$(stdlib_string_hex_decode "09")
assert "$stdout" == $'\t'
