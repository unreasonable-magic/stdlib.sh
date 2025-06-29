eval "$(stdlib shellenv)"

stdlib::import "assert"
stdlib::import "string/titleize"

declare out=""
declare stdout=""

inflector "titleize" -v out < <(echo -en $'DR WHO\nTIME LORD')
assert "${out}" == $'Dr Who\nTime Lord'

inflector "titleize" -v out < <(echo -en $'DR WHO\nTIME LORD\n')
assert "${out}" == $'Dr Who\nTime Lord\n'

stdout=$(titleize "hello world")
assert "$stdout" == "Hello World"

stdout=$(titleize "the lord of the rings")
assert "$stdout" == "The Lord Of The Rings"

stdout=$(titleize $'mighty morphin\npower rangers')
assert "$stdout" == $'Mighty Morphin\nPower Rangers'

titleize -v out "FROM a VAR"
assert "$out" == "From A Var"
