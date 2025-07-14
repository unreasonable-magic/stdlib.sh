eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/pluralize"

stdout=$(stdlib_string_pluralize "book")
assert "$stdout" == "books"

stdout=$(stdlib_string_pluralize "box")
assert "$stdout" == "boxes"

stdout=$(stdlib_string_pluralize "quiz")
assert "$stdout" == "quizes"

stdout=$(stdlib_string_pluralize "log")
assert "$stdout" == "logs"
