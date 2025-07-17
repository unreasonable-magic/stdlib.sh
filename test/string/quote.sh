eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/quote"

stdout=$(stdlib_string_quote 'hello')
assert "$stdout" == '"hello"'

stdout=$(stdlib_string_quote --single 'hello')
assert "$stdout" == "'hello'"

stdout=$(stdlib_string_quote '1234')
assert "$stdout" == '"1234"'

stdout=$(stdlib_string_quote --single '1234')
assert "$stdout" == "'1234'"

stdout=$(stdlib_string_quote '_')
assert "$stdout" == '"_"'

stdout=$(stdlib_string_quote --single '_')
assert "$stdout" == "'_'"

stdout=$(stdlib_string_quote $'this\nline')
assert "$stdout" == $'"this\nline"'

stdout=$(stdlib_string_quote --single $'this\nline')
assert "$stdout" == $'\'this\nline\''

stdout=$(stdlib_string_quote 'this has "double quotes"')
assert "$stdout" == '"this has \"double quotes\""'

stdout=$(stdlib_string_quote --single 'this has "double quotes"')
assert "$stdout" == ''\''this has "double quotes"'\'''

stdout=$(stdlib_string_quote "this has 'single quotes'")
assert "$stdout" == "\"this has 'single quotes'\""

stdout=$(stdlib_string_quote --single "this has 'single quotes'")
assert "$stdout" == "'this has '\''single quotes'\'''"
