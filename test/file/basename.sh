eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "file/basename"

stdout=$(stdlib_file_basename "hello.txt")
assert "$stdout" == "hello.txt"

stdout=$(stdlib_file_basename "hello.txt" ".txt")
assert "$stdout" == "hello"

stdout=$(stdlib_file_basename "hello.txt" ".png")
assert "$stdout" == "hello.txt"

stdout=$(stdlib_file_basename "hello.txt" ".*")
assert "$stdout" == "hello"
