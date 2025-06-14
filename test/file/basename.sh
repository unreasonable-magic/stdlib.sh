eval "$(stdlib shellenv)"

stdlib::import "assert"
stdlib::import "file/basename"

stdout=$(basename "hello.txt")
stdlib::assert [ "$stdout" == "hello.txt" ]

stdout=$(basename "hello.txt" ".txt")
stdlib::assert [ "$stdout" == "hello" ]

stdout=$(basename "hello.txt" ".png")
stdlib::assert [ "$stdout" == "hello.txt" ]

stdout=$(basename "hello.txt" ".*")
stdlib::assert [ "$stdout" == "hello" ]
