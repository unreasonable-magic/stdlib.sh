eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/underscore"
stdlib_import "debugger"

stdout=$(stdlib_string_underscore "camelCaseVariable")
assert "$stdout" == "camel_case_variable"

stdout=$(stdlib_string_underscore "MyClassName")
assert "$stdout" == "my_class_name"

stdout=$(stdlib_string_underscore "this has spaces")
assert "$stdout" == "this_has_spaces"
