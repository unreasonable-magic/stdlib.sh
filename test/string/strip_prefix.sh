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