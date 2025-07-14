eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/dequote"

stdout=$(stdlib_string_dequote '"hello world"')
assert "$stdout" == "hello world"

stdout=$(stdlib_string_dequote "'hello world'")
assert "$stdout" == "hello world"

stdout=$(stdlib_string_dequote '"He said \"hello\" to me"')
assert "$stdout" == 'He said "hello" to me'

stdout=$(stdlib_string_dequote "'It\'s a beautiful day'")
assert "$stdout" == "It's a beautiful day"

stdout=$(stdlib_string_dequote "hello world")
assert "$stdout" == "hello world"

stdout=$(stdlib_string_dequote '"hello world'\''')
assert "$stdout" == '"hello world'\'''

stdout=$(stdlib_string_dequote '"hello world')
assert "$stdout" == '"hello world'

stdout=$(stdlib_string_dequote 'hello world"')
assert "$stdout" == 'hello world"'

stdout=$(stdlib_string_dequote "")
assert "$stdout" == ""

stdout=$(stdlib_string_dequote '""')
assert "$stdout" == ""

stdout=$(stdlib_string_dequote "''")
assert "$stdout" == ""

stdout=$(stdlib_string_dequote '"a"')
assert "$stdout" == "a"

stdout=$(stdlib_string_dequote '"I said \"I don'\''t know\" twice"')
assert "$stdout" == 'I said "I don'\''t know" twice'

stdout=$(stdlib_string_dequote "\"'\''hello world'\''\"")
assert "$stdout" == "'\''hello world'\''"

stdout=$(stdlib_string_dequote '"hello')
assert "$stdout" == '"hello'

stdout=$(stdlib_string_dequote 'hello"')
assert "$stdout" == 'hello"'
