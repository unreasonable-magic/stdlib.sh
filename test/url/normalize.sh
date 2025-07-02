eval "$(stdlib shellenv)"

stdlib::import "assert"
stdlib::import "url/normalize"

stdout=$(urlnormalize "HTTPS://EXAMPLE.COM:443/PATH/")
assert "$stdout" == "https://example.com/PATH"

stdout=$(urlnormalize "example.com/path")
assert "$stdout" == "http://example.com/path"

stdout=$(urlnormalize "example.com/#")
assert "$stdout" == "http://example.com"

stdout=$(urlnormalize "example.com:80")
assert "$stdout" == "http://example.com"

stdout=$(urlnormalize "https://example.com/blah")
assert "$stdout" == "https://example.com/blah"

stdout=$(urlnormalize "https://example.com/blah?a=1&b=2")
assert "$stdout" == "https://example.com/blah?a=1&b=2"

stdout=$(urlnormalize "https://example.com/blah#toast")
assert "$stdout" == "https://example.com/blah#toast"

stdout=$(urlnormalize "https://example.com/blah?a=1#toast")
assert "$stdout" == "https://example.com/blah?a=1#toast"

stdout=$(urlnormalize "/foo/bar" --base "example.com")
assert "$stdout" == "http://example.com/foo/bar"

stdout=$(urlnormalize "/foo/bar" --base "https://example.com")
assert "$stdout" == "https://example.com/foo/bar"

stdout=$(urlnormalize "example.com/path" --base "different.com")
assert "$stdout" == "http://example.com/path"

urlnormalize -v out "https://example.com/path/?"
assert "$out" == "https://example.com/path"
