eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/titleize"

declare out=""
declare stdout=""

stdlib_string_titleize -v out < <(echo -en $'DR WHO\nTIME LORD')
assert "${out}" == $'Dr Who\nTime Lord'

stdlib_string_titleize -v out < <(echo -en $'DR WHO\nTIME LORD\n')
assert "${out}" == $'Dr Who\nTime Lord\n'

stdout=$(stdlib_string_titleize "hello world")
assert "$stdout" == "Hello World"

stdout=$(stdlib_string_titleize "the lord of the rings")
assert "$stdout" == "The Lord Of The Rings"

stdout=$(stdlib_string_titleize $'mighty morphin\npower rangers')
assert "$stdout" == $'Mighty Morphin\nPower Rangers'

stdlib_string_titleize -v out "FROM a VAR"
assert "$out" == "From A Var"
