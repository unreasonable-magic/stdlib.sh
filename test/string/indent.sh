eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/indent"

string="indent
via
param"
stdout=$(stdlib_string_indent "$string" 4)
assert "$stdout" == $'    indent\n    via\n    param'

string="indent
  via
stdin"
stdout=$(printf "$string" | stdlib_string_indent 2)
assert "$stdout" == $'  indent\n    via\n  stdin'
