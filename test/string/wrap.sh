eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/wrap"

# Test basic wrapping
stdlib_string_wrap -v wrapped "The quick brown fox jumps over the lazy dog" -c 20
expected="The quick brown fox\njumps over the lazy\ndog"
assert "$wrapped" == "$expected"

# Test wrapping with default 80 columns
stdlib_string_wrap -v wrapped "This is a short line"
assert "$wrapped" == "This is a short line"

# Test hard break for long words
stdlib_string_wrap -v wrapped "supercalifragilisticexpialidocious" -c 10
expected="supercalif\nragilistic\nexpialidoc\nious"
assert "$wrapped" == "$expected"

# Test mixed content with long words
stdlib_string_wrap -v wrapped "This supercalifragilisticexpialidocious word needs breaking" -c 15
expected="This\nsupercalifragil\nisticexpialidoc\nious word needs\nbreaking"
assert "$wrapped" == "$expected"

# Test empty string
stdlib_string_wrap -v wrapped "" -c 10
assert "$wrapped" == ""

# Test multiple paragraphs
text="First paragraph here.

Second paragraph here."
stdlib_string_wrap -v wrapped "$text" -c 15
expected="First paragraph\nhere.\n\nSecond\nparagraph here."
assert "$wrapped" == "$expected"

# Test wrapping at exact column boundary
stdlib_string_wrap -v wrapped "12345 67890" -c 5
expected="12345\n67890"
assert "$wrapped" == "$expected"

# Test wrapping with stdin
wrapped=$(echo "The quick brown fox" | stdlib_string_wrap -c 10)
expected=$'The quick\nbrown fox'
assert "$wrapped" == "$expected"

# Test wrapping with longer text
long_text="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
stdlib_string_wrap -v wrapped "$long_text" -c 40
expected="Lorem ipsum dolor sit amet, consectetur\nadipiscing elit. Sed do eiusmod tempor\nincididunt ut labore et dolore magna\naliqua."
assert "$wrapped" == "$expected"

# Test edge case with word exactly at column limit
stdlib_string_wrap -v wrapped "test word" -c 4
expected="test\nword"
assert "$wrapped" == "$expected"