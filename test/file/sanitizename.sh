eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "file/sanitizename"

stdout=$(echo "via stdin::  " | stdlib_file_sanitizename)
assert "$stdout" == "via stdin"

stdout=$(stdlib_file_sanitizename "x x")
assert "$stdout" == "x x"

stdout=$(stdlib_file_sanitizename "https://example.com/foo/bar")
assert "$stdout" == "httpsexample.comfoobar"

stdout=$(stdlib_file_sanitizename "a")
assert "$stdout" == "a"

stdout=$(stdlib_file_sanitizename "a ")
assert "$stdout" == "a"

stdout=$(stdlib_file_sanitizename " a")
assert "$stdout" == "a"

stdout=$(stdlib_file_sanitizename " a ")
assert "$stdout" == "a"

stdout=$(stdlib_file_sanitizename $' a   \n')
assert "$stdout" == "a"

stdout=$(stdlib_file_sanitizename "x x")
assert "$stdout" == "x x"

stdout=$(stdlib_file_sanitizename "x | x")
assert "$stdout" == "x x"

stdout=$(stdlib_file_sanitizename $'x\r\nx')
assert "$stdout" == "xx"

stdout=$(stdlib_file_sanitizename "<")
assert "$stdout" == "file"

stdout=$(stdlib_file_sanitizename "<a")
assert "$stdout" == "a"

stdout=$(stdlib_file_sanitizename ">")
assert "$stdout" == "file"

stdout=$(stdlib_file_sanitizename "a>")
assert "$stdout" == "a"

stdout=$(stdlib_file_sanitizename "a>a")
assert "$stdout" == "aa"

stdout=$(stdlib_file_sanitizename "< > | / \\ * ? :")
assert "$stdout" == "file"

stdout=$(stdlib_file_sanitizename $'what\\ēver//wëird:user:înput:')
assert "$stdout" == "whatēverwëirduserînput"
