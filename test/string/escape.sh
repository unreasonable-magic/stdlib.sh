eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/escape"

stdout=$(stdlib_string_escape 'hello')
assert "$stdout" == 'hello'

stdout=$(stdlib_string_escape '')
assert "$stdout" == ''

stdout=$(stdlib_string_escape $'this\nline')
assert "$stdout" == "this\nline"

stdout=$(stdlib_string_escape 'hello world')
assert "$stdout" == "hello world"

stdout=$(stdlib_string_escape $'\e[0m \r \t')
assert "$stdout" == "\\E[0m \\r \\t"

stdout=$(stdlib_string_escape 'this has "double" quotes')
assert "$stdout" == 'this has "double" quotes'

stdout=$(stdlib_string_escape "this has 'single' quotes")
assert "$stdout" == "this has 'single' quotes"
