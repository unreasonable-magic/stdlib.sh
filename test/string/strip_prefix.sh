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