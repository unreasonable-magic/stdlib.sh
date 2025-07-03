eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "maths/divide"

stdout=$(stdlib_maths_divide 30 12)
assert "$stdout" == "2.5"

stdout=$(stdlib_maths_divide "55" "16")
assert "$stdout" == "3.4375"

stdout=$(stdlib_maths_divide "100.5" "25")
assert "$stdout" == "4.02"

stdout=$(stdlib_maths_divide "123.456" "78.9")
assert "$stdout" == "1.564714"

stdout=$(stdlib_maths_divide --precision 1 "123.456" "78.9")
assert "$stdout" == "1.5"

stdout=$(stdlib_maths_divide --precision 9 "123.456" "78.9")
assert "$stdout" == "1.564714828"
