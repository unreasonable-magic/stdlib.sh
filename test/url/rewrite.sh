eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "url/rewrite"
stdlib_import "log"

stdout=$(stdlib_url_rewrite "https://example.com/users/1" --host=test.com)
assert "$stdout" == "https://test.com/users/1"

stdout=$(stdlib_url_rewrite "/users/1" --host=example.com)
assert "$stdout" == "example.com/users/1"

stdout=$(stdlib_url_rewrite "https://example.com/users/1" --scheme=ftp --path="robots.txt")
assert "$stdout" == "ftp://example.com/robots.txt"

stdout=$(stdlib_url_rewrite "https://example.com/users/1" --query=?foo=bar --fragment="#root")
assert "$stdout" == "https://example.com/users/1?foo=bar#root"

stdout=$(stdlib_url_rewrite "https://example.com/users/1" --query=foo=bar --fragment="root")
assert "$stdout" == "https://example.com/users/1?foo=bar#root"

stdout=$(stdlib_url_rewrite "https://example.com/users/1" --path="")
assert "$stdout" == "https://example.com"

stdout=$(stdlib_url_rewrite "https://example.com/users/1" --scheme="" --path="")
assert "$stdout" == "example.com"

stdout=$(stdlib_url_rewrite "https://example.com/users/1" --host="")
assert "$stdout" == "https:///users/1"

stdlib_url_rewrite -v out "https://example.com/users/1" --host=test.com
assert "$out" == "https://test.com/users/1"
