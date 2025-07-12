eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/pad"

stdout=$(stdlib_string_pad --width 5 "a")
assert "$stdout" == "a    "

stdout=$(stdlib_string_pad --width 5 --align left "a")
assert "$stdout" == "a    "

stdout=$(stdlib_string_pad --width 5 --align center "a")
assert "$stdout" == "  a  "

stdout=$(stdlib_string_pad --width 5 --align right "a")
assert "$stdout" == "    a"

stdout=$(stdlib_string_pad --width 15 --align left "Suprêmes")
assert "$stdout" == "Suprêmes       "

stdout=$(stdlib_string_pad --width 15 --align center "Suprêmes")
assert "$stdout" == "   Suprêmes    "

stdout=$(stdlib_string_pad --width 15 --align right "Suprêmes")
assert "$stdout" == "       Suprêmes"

stdout=$(stdlib_string_pad --width 15 --align left "Supremes")
assert "$stdout" == "Supremes       "

stdout=$(stdlib_string_pad --width 15 --align center "Supremes")
assert "$stdout" == "   Supremes    "

stdout=$(stdlib_string_pad --width 15 --align right "Supremes")
assert "$stdout" == "       Supremes"
