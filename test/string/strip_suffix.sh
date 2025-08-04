eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/strip_suffix"

declare out=""
declare stdout=""

stdout=$(stdlib_string_strip_suffix "hello-world" "-world")
assert "$stdout" == "hello"

stdout=$(stdlib_string_strip_suffix "TestSuffix" "Suffix")
assert "$stdout" == "Test"

stdout=$(stdlib_string_strip_suffix "no-match" "suffix")
assert "$stdout" == "no-match"

stdout=$(stdlib_string_strip_suffix "test" "test")
assert "$stdout" == ""

stdout=$(echo "content-stdin" | stdlib_string_strip_suffix "-stdin")
assert "$stdout" == "content"

stdlib_string_strip_suffix -v out "content-var" "-var"
assert "$out" == "content"

# Test with newline in suffix
stdout=$(printf "blah\nhello world" | stdlib_string_strip_suffix "
hello world")
assert "$stdout" == "blah"

# Test with newline using $'...' syntax
stdout=$(stdlib_string_strip_suffix $'first line\nsecond line' $'\nsecond line')
assert "$stdout" == "first line"

# Test with multiple newlines
stdout=$(stdlib_string_strip_suffix $'content\n\nsuffix' $'\n\nsuffix')
assert "$stdout" == "content"