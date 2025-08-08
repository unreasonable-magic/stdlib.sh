eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/strip_prefix"

declare out=""
declare stdout=""

stdout=$(stdlib_string_strip_prefix "hello-world" "hello-")
assert "$stdout" == "world"

stdout=$(stdlib_string_strip_prefix "prefixTest" "prefix")
assert "$stdout" == "Test"

stdout=$(stdlib_string_strip_prefix "no-match" "prefix")
assert "$stdout" == "no-match"

stdout=$(stdlib_string_strip_prefix "test" "test")
assert "$stdout" == ""

stdout=$(echo "stdin-content" | stdlib_string_strip_prefix "stdin-")
assert "$stdout" == "content"

stdlib_string_strip_prefix -v out "var-content" "var-"
assert "$out" == "content"

# Test with newline in prefix
stdout=$(printf "hello world\nblah" | stdlib_string_strip_prefix "hello world
")
assert "$stdout" == "blah"

# Test with newline using $'...' syntax
stdout=$(stdlib_string_strip_prefix $'first line\nsecond line' $'first line\n')
assert "$stdout" == "second line"

# Test with multiple newlines
stdout=$(stdlib_string_strip_prefix $'prefix\n\ncontent' $'prefix\n\n')
assert "$stdout" == "content"

# Test that newlines at the end are NOT stripped (only from prefix)
stdout=$(stdlib_string_strip_prefix $'content\n' $'\n')
assert "$stdout" == $'content\n'

# Test that newlines in the middle and end are preserved
stdout=$(stdlib_string_strip_prefix $'hello\nworld\n' 'hello')
assert "$stdout" == $'\nworld\n'

# Test that trailing newlines are preserved when prefix matches beginning
stdout=$(stdlib_string_strip_prefix $'prefix content\n\n' 'prefix ')
assert "$stdout" == $'content\n\n'

# Test that only exact prefix is stripped, not suffix with same characters
stdout=$(stdlib_string_strip_prefix $'\ntext\n' $'\n')
assert "$stdout" == $'text\n'

# Test complex case: prefix with newline, content with trailing newlines
stdout=$(stdlib_string_strip_prefix $'start\ndata\nend\n\n' $'start\n')
assert "$stdout" == $'data\nend\n\n'

# Test that empty lines at end are preserved
stdout=$(stdlib_string_strip_prefix $'header\nbody\n\n\n' 'header')
assert "$stdout" == $'\nbody\n\n\n'