eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "url/parse"
stdlib_import "log"

stdout=$(stdlib_url_parse "https://example.com/users/1" --host)
assert "$stdout" == "example.com"

stdout=$(stdlib_url_parse "https://example.com/users/1" --path)
assert "$stdout" == "/users/1"

stdout=$(stdlib_url_parse "https://example.com/users/1" --path --host)
assert "$stdout" == $'/users/1\nexample.com'

stdout=$(stdlib_url_parse "https://example.com/users/1" --scheme --host --port --path --query --fragment)
assert "$stdout" == $'https\nexample.com\n\n/users/1'

stdout=$(stdlib_url_parse "example.com" --scheme --host --port --path --query --fragment)
assert "$stdout" == $'\nexample.com'

stdlib_url_parse -v out "https://example.com/users/1" --path --host
assert "$out" == $'/users/1\nexample.com'
