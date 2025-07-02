eval "$(stdlib shellenv)"

stdlib::import "assert"
stdlib::import "file/sanitizename"


stdout=$(filesanitizename "x x")
assert "$stdout" == "x x"

stdout=$(filesanitizename "https://example.com/foo/bar")
assert "$stdout" == "httpsexample.comfoobar"

stdout=$(filesanitizename "a")
assert "$stdout" == "a"

stdout=$(filesanitizename "a ")
assert "$stdout" == "a"

stdout=$(filesanitizename " a")
assert "$stdout" == "a"

stdout=$(filesanitizename " a ")
assert "$stdout" == "a"

stdout=$(filesanitizename $' a   \n')
assert "$stdout" == "a"

stdout=$(filesanitizename "x x")
assert "$stdout" == "x x"

stdout=$(filesanitizename "x | x")
assert "$stdout" == "x x"

stdout=$(filesanitizename $'x\r\nx')
assert "$stdout" == "xx"

stdout=$(filesanitizename "<")
assert "$stdout" == "file"

stdout=$(filesanitizename "<a")
assert "$stdout" == "a"

stdout=$(filesanitizename ">")
assert "$stdout" == "file"

stdout=$(filesanitizename "a>")
assert "$stdout" == "a"

stdout=$(filesanitizename "a>a")
assert "$stdout" == "aa"

stdout=$(filesanitizename "< > | / \\ * ? :")
assert "$stdout" == "file"

stdout=$(filesanitizename $'what\\ēver//wëird:user:înput:')
assert "$stdout" == "whatēverwëirduserînput"
