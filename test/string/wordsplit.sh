for arg in "$@"; do
  echo "LL $arg"
done

eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "string/wordsplit"

stdout=$(stdlib_string_wordsplit 'hello')
assert "$stdout" == 'hello'

stdout=$(stdlib_string_wordsplit 'multiple things here')
assert "$stdout" == $'multiple\nthings\nhere'

stdout=$(stdlib_string_wordsplit "'this will split' 'and so will this'")
assert "$stdout" == $'this will split\nand so will this'

stdout=$(stdlib_string_wordsplit 'start --something="foo bar" --and-another='\''blah'\'' finish')
assert "$stdout" == $'start\n--something=foo bar\n--and-another=blah\nfinish'

stdout=$(stdlib_string_wordsplit "'start \" here' 'wont \" end here'")
assert "$stdout" == $'start " here\nwont " end here'

stdout=$(stdlib_string_wordsplit "\"it's\"=\"got's to be good\" this=is")
assert "$stdout" == $'it\'s=got\'s to be good\nthis=is'
