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

# Test count parameter
assert "$(stdlib_string_pluralize "book" 1)" == "book"
assert "$(stdlib_string_pluralize "book" 2)" == "books"
assert "$(stdlib_string_pluralize "book" 0)" == "books"

assert "$(stdlib_string_pluralize "box" 1)" == "box"
assert "$(stdlib_string_pluralize "box" 3)" == "boxes"

assert "$(stdlib_string_pluralize "baby" 1)" == "baby"
assert "$(stdlib_string_pluralize "baby" 2)" == "babies"

assert "$(stdlib_string_pluralize "man" 1)" == "man"
assert "$(stdlib_string_pluralize "man" 2)" == "men"

assert "$(stdlib_string_pluralize "child" 1)" == "child"
assert "$(stdlib_string_pluralize "child" 5)" == "children"

# Test with already plural words
assert "$(stdlib_string_pluralize "children" 1)" == "child"
assert "$(stdlib_string_pluralize "mice" 1)" == "mouse"
assert "$(stdlib_string_pluralize "boxes" 1)" == "box"

# Test with fractional numbers
assert "$(stdlib_string_pluralize "second" 0.5)" == "seconds"
assert "$(stdlib_string_pluralize "second" 1.5)" == "seconds"
assert "$(stdlib_string_pluralize "second" 2.5)" == "seconds"
assert "$(stdlib_string_pluralize "second" 1)" == "second"
assert "$(stdlib_string_pluralize "second" 1.0)" == "second"
assert "$(stdlib_string_pluralize "second" 1.00)" == "second"
assert "$(stdlib_string_pluralize "second" 0)" == "seconds"
assert "$(stdlib_string_pluralize "minute" 0.25)" == "minutes"
assert "$(stdlib_string_pluralize "hour" 1.75)" == "hours"
