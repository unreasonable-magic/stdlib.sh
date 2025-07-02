eval "$(stdlib shellenv)"

stdlib::import "assert"
stdlib::import "url/parse"
stdlib::import "log"

stdout=$(urlparse "https://example.com/users/1" --host)
assert "$stdout" == "example.com"

stdout=$(urlparse "https://example.com/users/1" --path)
assert "$stdout" == "/users/1"

stdout=$(urlparse "https://example.com/users/1" --path --host)
assert "$stdout" == $'/users/1\nexample.com'

stdout=$(urlparse "https://example.com/users/1" --scheme --host --port --path --query --fragment)
assert "$stdout" == $'https\nexample.com\n\n/users/1'

stdout=$(urlparse "example.com" --scheme --host --port --path --query --fragment)
assert "$stdout" == $'\nexample.com'

urlparse -v out "https://example.com/users/1" --path --host
assert "$out" == $'/users/1\nexample.com'
