eval "$(stdlib shellenv)"

stdlib::import "assert"
stdlib::import "maths/divide"

stdout=$(divide 30 12)
assert "$stdout" == "2.5"

stdout=$(divide "55" "16")
assert "$stdout" == "3.4375"

stdout=$(divide "100.5" "25")
assert "$stdout" == "4.02"

stdout=$(divide "123.456" "78.9")
assert "$stdout" == "1.564714"

stdout=$(divide --precision 1 "123.456" "78.9")
assert "$stdout" == "1.5"

stdout=$(divide --precision 9 "123.456" "78.9")
assert "$stdout" == "1.564714828"
