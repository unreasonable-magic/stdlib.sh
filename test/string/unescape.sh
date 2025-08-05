eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/escape"
stdlib_import "string/unescape"

declare stdout=""

# Test basic unescape functionality
stdout=$(stdlib_string_unescape 'hello')
assert "$stdout" == 'hello'

stdout=$(stdlib_string_unescape '')
assert "$stdout" == ''

stdout=$(stdlib_string_unescape $'this\nline')
assert "$stdout" == $'this\nline'

stdout=$(stdlib_string_unescape "hello world")
assert "$stdout" == "hello world"

stdout=$(stdlib_string_unescape 'this has "double" quotes')
assert "$stdout" == 'this has "double" quotes'

stdout=$(stdlib_string_unescape "this has 'single' quotes")
assert "$stdout" == "this has 'single' quotes"

# Test with double backslashes
stdout=$(stdlib_string_unescape 'C:\\path\\to\\file')
assert "$stdout" == 'C:\path\to\file'

# Test ANSI escape codes 
stdout=$(stdlib_string_unescape $'\e[31mred\e[0m')
assert "$stdout" == $'\e[31mred\e[0m'

# Test round-trip: escape then unescape should restore original
declare original=""
declare escaped=""
declare unescaped=""

# Simple string
original="hello world"
escaped=$(stdlib_string_escape "$original")
unescaped=$(stdlib_string_unescape "$escaped")
assert "$unescaped" == "$original"

# String with quotes
original='He said "Hello" and she said '\''Hi'\'''
escaped=$(stdlib_string_escape "$original")
unescaped=$(stdlib_string_unescape "$escaped")
assert "$unescaped" == "$original"

# String with forward slashes (no escape issues)
original='/home/user/documents'
escaped=$(stdlib_string_escape "$original")
unescaped=$(stdlib_string_unescape "$escaped")
assert "$unescaped" == "$original"

# Empty string round-trip
original=""
escaped=$(stdlib_string_escape "$original")
unescaped=$(stdlib_string_unescape "$escaped")
assert "$unescaped" == "$original"

# String with unicode
original="Hello 🌍 World"
escaped=$(stdlib_string_escape "$original")
unescaped=$(stdlib_string_unescape "$escaped")
assert "$unescaped" == "$original"

# String with spaces and special punctuation
original='path/to/some file! (with special chars) & more'
escaped=$(stdlib_string_escape "$original")
unescaped=$(stdlib_string_unescape "$escaped")
assert "$unescaped" == "$original"

# String with dollar signs
original='$HOME is where the $HEART is'
escaped=$(stdlib_string_escape "$original")
unescaped=$(stdlib_string_unescape "$escaped")
assert "$unescaped" == "$original"