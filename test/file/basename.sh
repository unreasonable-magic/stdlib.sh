eval "$(stdlib shellenv)"

stdlib::import "assert"
stdlib::import "file/basename"

stdout=$(basename "hello.txt")
assert "$stdout" == "hello.txt"

stdout=$(basename "hello.txt" ".txt")
assert "$stdout" == "hello"

stdout=$(basename "hello.txt" ".png")
assert "$stdout" == "hello.txt"

stdout=$(basename "hello.txt" ".*")
assert "$stdout" == "hello"
