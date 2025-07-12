eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/count"

stdout=$(stdlib_string_count "foo" "bar")
assert "$stdout" == "0"

stdout=$(stdlib_string_count "foo" "bar")
assert "$stdout" == "0"

stdout=$(stdlib_string_count "foo" "foo")
assert "$stdout" == "1"

stdout=$(stdlib_string_count "foo foo foo" "foo")
assert "$stdout" == "3"

stdout=$(stdlib_string_count "*bold* is a style" "*")
assert "$stdout" == "2"

stdout=$(stdlib_string_count $'works \t with \t tabs' $'\t')
assert "$stdout" == "2"

stdout=$(stdlib_string_count $'ignores \\t escaped \\t tabs' $'\t')
assert "$stdout" == "0"

stdout=$(stdlib_string_count $'works \n with \n new \n lines' $'\n')
assert "$stdout" == "3"

stdout=$(stdlib_string_count $'ignores \\n escaped \\n new \\n lines' $'\n')
assert "$stdout" == "0"

stdout=$(stdlib_string_count "     " " ")
assert "$stdout" == "5"
