eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "maths/multiply"

stdout=$(stdlib_maths_multiply 30 12)
assert "$stdout" == "360"

stdout=$(stdlib_maths_multiply "55" "16")
assert "$stdout" == "880"

stdout=$(stdlib_maths_multiply "100.5" "25")
assert "$stdout" == "2512.5"

stdout=$(stdlib_maths_multiply "123.456" "78.9")
assert "$stdout" == "9740.6784"

stdout=$(stdlib_maths_multiply --precision 1 "123.456" "78.9")
assert "$stdout" == "9740.6"

stdout=$(stdlib_maths_multiply "2.5" "4")
assert "$stdout" == "10"

stdout=$(stdlib_maths_multiply "0.1" "0.2")
assert "$stdout" == "0.02"

stdout=$(stdlib_maths_multiply "3.14159" "2")
assert "$stdout" == "6.28318"

stdout=$(stdlib_maths_multiply "1.5" "2.5")
assert "$stdout" == "3.75"

stdout=$(stdlib_maths_multiply "0.900000" "1000")
assert "$stdout" == "900"
