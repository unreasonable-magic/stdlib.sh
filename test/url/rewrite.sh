eval "$(stdlib shellenv)"

stdlib::import "assert"
stdlib::import "url/rewrite"
stdlib::import "log"

stdout=$(urlrewrite "https://example.com/users/1" --host=test.com)
assert "$stdout" == "https://test.com/users/1"

stdout=$(urlrewrite "/users/1" --host=example.com)
assert "$stdout" == "example.com/users/1"

stdout=$(urlrewrite "https://example.com/users/1" --scheme=ftp --path="robots.txt")
assert "$stdout" == "ftp://example.com/robots.txt"

stdout=$(urlrewrite "https://example.com/users/1" --query=?foo=bar --fragment="#root")
assert "$stdout" == "https://example.com/users/1?foo=bar#root"

stdout=$(urlrewrite "https://example.com/users/1" --query=foo=bar --fragment="root")
assert "$stdout" == "https://example.com/users/1?foo=bar#root"

stdout=$(urlrewrite "https://example.com/users/1" --path="")
assert "$stdout" == "https://example.com"

stdout=$(urlrewrite "https://example.com/users/1" --scheme="" --path="")
assert "$stdout" == "example.com"

stdout=$(urlrewrite "https://example.com/users/1" --host="")
assert "$stdout" == "https:///users/1"

urlrewrite -v out "https://example.com/users/1" --host=test.com
assert "$out" == "https://test.com/users/1"
