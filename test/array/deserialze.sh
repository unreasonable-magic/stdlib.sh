eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "array/serialize"
stdlib_import "array/deserialize"

declare -A my_assoc_array=(["this"]="is" ["it's"]="got's to be good")
declare -A deserialized_assoc
stdlib_array_deserialize -A deserialized_assoc "$(stdlib_array_serialize -A my_assoc_array)"
assert "${#deserialized_assoc[@]}" == 2
assert "${deserialized_assoc['this']}" == 'is'
assert "${deserialized_assoc["it's"]}" == "got's to be good"

declare -A my_assoc_array=(["this"]="is" ["it's"]="got's to be good")
declare -A deserialized_assoc
stdlib_array_deserialize -A deserialized_assoc "$(stdlib_array_serialize --compact -A my_assoc_array)"
assert "${#deserialized_assoc[@]}" == 2
assert "${deserialized_assoc['this']}" == 'is'
assert "${deserialized_assoc["it's"]}" == "got's to be good"

declare -a my_array=("great" "things" "here")
declare -a deserialized_array
stdlib_array_deserialize -a deserialized_array "$(stdlib_array_serialize -a my_array)"
assert "${#deserialized_array[@]}" == 3
assert "${deserialized_array[0]}" == 'great'
assert "${deserialized_array[1]}" == "things"
assert "${deserialized_array[2]}" == "here"

declare -a my_array=("great" "things" "here")
declare -a deserialized_array
stdlib_array_deserialize -a deserialized_array "$(stdlib_array_serialize --compact -a my_array)"
assert "${#deserialized_array[@]}" == 3
assert "${deserialized_array[0]}" == 'great'
assert "${deserialized_array[1]}" == "things"
assert "${deserialized_array[2]}" == "here"
