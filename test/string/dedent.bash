eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/dedent"

string="
  this
  will
    be
  fixed
"
stdout=$(printf "$string" | stdlib_string_dedent)
assert "$stdout" == $'this\nwill\n  be\nfixed'

string="
#   this
#   will
#     be
#   fixed
"
stdout=$(printf "$string" | stdlib_string_dedent --prefix "#")
assert "$stdout" == $'this\nwill\n  be\nfixed'

string="
  this
  will
    be
  fixed
"
stdout=$(stdlib_string_dedent "$string")
assert "$stdout" == $'this\nwill\n  be\nfixed'

string="
indentation
is
zero
"
stdout=$(printf "$string" | stdlib_string_dedent)
assert "$stdout" == $'indentation\nis\nzero'

string="
"
stdout=$(printf "$string" | stdlib_string_dedent)
assert "$stdout" == ""

string="


"
stdout=$(printf "$string" | stdlib_string_dedent)
assert "$stdout" == ""

string="
   smallest
 space
   wins
"
stdout=$(printf "$string" | stdlib_string_dedent)
assert "$stdout" == $'  smallest\nspace\n  wins'
