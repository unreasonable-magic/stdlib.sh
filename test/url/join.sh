eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "url/join"

stdout=$(stdlib_url_join "https://example.com" "users" "1")
assert "$stdout" == "https://example.com/users/1"

stdout=$(stdlib_url_join "https://example.com/" "/users/" "/1")
assert "$stdout" == "https://example.com/users/1"

stdout=$(stdlib_url_join "/" "/users/" "/1")
assert "$stdout" == "/users/1"

stdlib_url_join -v out "/" "/users/" "/1"
assert "$out" == "/users/1"
