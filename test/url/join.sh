eval "$(stdlib shellenv)"

stdlib::import "assert"
stdlib::import "url/join"

stdout=$(urljoin "https://example.com" "users" "1")
assert "$stdout" == "https://example.com/users/1"

stdout=$(urljoin "https://example.com/" "/users/" "/1")
assert "$stdout" == "https://example.com/users/1"

stdout=$(urljoin "/" "/users/" "/1")
assert "$stdout" == "/users/1"

urljoin -v out "/" "/users/" "/1"
assert "$out" == "/users/1"
