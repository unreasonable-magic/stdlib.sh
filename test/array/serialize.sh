eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "array/serialize"

declare -ga my_array=("this" "is" "my" "array")
stdout="$(stdlib_array_serialize -a my_array)"
assert "$stdout" == $'0=this\n1=is\n2=my\n3=array'

declare -ga my_array=("this" "is" "my" "array")
my_array[10]="number 10"
stdout="$(stdlib_array_serialize -a my_array)"
assert "$stdout" == $'0=this\n1=is\n2=my\n3=array\n10="number 10"'

declare -ga my_array=("this" "is" "my" "array")
stdout="$(stdlib_array_serialize --compact -a my_array)"
assert "$stdout" == "0=this 1=is 2=my 3=array"

declare -ga my_array=('this has "quotes"' "so 'does' this")
stdout="$(stdlib_array_serialize -a my_array)"
assert "$stdout" == $'0="this has \\"quotes\\""\n1="so \'does\' this"'

declare -ga my_array=()
stdout="$(stdlib_array_serialize -a my_array)"
assert "$stdout" == $''

declare -gA my_assoc_array=(["this"]="is" ["my"]="array")
stdout="$(stdlib_array_serialize -A my_assoc_array)"
assert "$stdout" == $'my=array\nthis=is'

declare -gA my_assoc_array=(["this"]="is" ["my"]="array")
stdout="$(stdlib_array_serialize --compact -A my_assoc_array)"
assert "$stdout" == 'my=array this=is'

declare -gA my_assoc_array=([$'th\nis']=$'i\ns' [$'m\ny']=$'ar\nray')
stdout="$(stdlib_array_serialize --compact -A my_assoc_array)"
assert "$stdout" == "th\nis=i\ns m\ny=ar\nray"

declare -gA my_assoc_array=()
stdout="$(stdlib_array_serialize -A my_assoc_array)"
assert "$stdout" == $''
