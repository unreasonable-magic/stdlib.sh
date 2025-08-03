eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/singular"

# Test irregular plurals -> singular
assert "$(stdlib_string_singular "men")" == "man"
assert "$(stdlib_string_singular "women")" == "woman"
assert "$(stdlib_string_singular "children")" == "child"
assert "$(stdlib_string_singular "feet")" == "foot"
assert "$(stdlib_string_singular "teeth")" == "tooth"
assert "$(stdlib_string_singular "geese")" == "goose"
assert "$(stdlib_string_singular "mice")" == "mouse"
assert "$(stdlib_string_singular "people")" == "person"
assert "$(stdlib_string_singular "oxen")" == "ox"

# Test regular plurals -> singular
assert "$(stdlib_string_singular "cats")" == "cat"
assert "$(stdlib_string_singular "dogs")" == "dog"
assert "$(stdlib_string_singular "houses")" == "house"

# Test -es endings
assert "$(stdlib_string_singular "glasses")" == "glass"
assert "$(stdlib_string_singular "brushes")" == "brush"
assert "$(stdlib_string_singular "boxes")" == "box"
assert "$(stdlib_string_singular "watches")" == "watch"
assert "$(stdlib_string_singular "fizzes")" == "fizz"

# Test -ies endings
assert "$(stdlib_string_singular "babies")" == "baby"
assert "$(stdlib_string_singular "cities")" == "city"
assert "$(stdlib_string_singular "puppies")" == "puppy"

# Test -ves endings
assert "$(stdlib_string_singular "leaves")" == "leaf"
assert "$(stdlib_string_singular "wolves")" == "wolf"
assert "$(stdlib_string_singular "knives")" == "knife"
assert "$(stdlib_string_singular "wives")" == "wife"
assert "$(stdlib_string_singular "lives")" == "life"

# Test -oes endings
assert "$(stdlib_string_singular "heroes")" == "hero"
assert "$(stdlib_string_singular "potatoes")" == "potato"

# Test already singular words
assert "$(stdlib_string_singular "cat")" == "cat"
assert "$(stdlib_string_singular "dog")" == "dog"
assert "$(stdlib_string_singular "house")" == "house"