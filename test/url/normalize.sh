eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "url/normalize"

stdout=$(stdlib_url_normalize "HTTPS://EXAMPLE.COM:443/PATH/")
assert "$stdout" == "https://example.com/PATH"

stdout=$(stdlib_url_normalize "example.com/path")
assert "$stdout" == "http://example.com/path"

stdout=$(stdlib_url_normalize "example.com/#")
assert "$stdout" == "http://example.com"

stdout=$(stdlib_url_normalize "example.com:80")
assert "$stdout" == "http://example.com"

stdout=$(stdlib_url_normalize "https://example.com/blah")
assert "$stdout" == "https://example.com/blah"

stdout=$(stdlib_url_normalize "https://example.com/blah?a=1&b=2")
assert "$stdout" == "https://example.com/blah?a=1&b=2"

stdout=$(stdlib_url_normalize "https://example.com/blah#toast")
assert "$stdout" == "https://example.com/blah#toast"

stdout=$(stdlib_url_normalize "https://example.com/blah?a=1#toast")
assert "$stdout" == "https://example.com/blah?a=1#toast"

stdout=$(stdlib_url_normalize "/foo/bar" --base "example.com")
assert "$stdout" == "http://example.com/foo/bar"

stdout=$(stdlib_url_normalize "/foo/bar" --base "https://example.com")
assert "$stdout" == "https://example.com/foo/bar"

stdout=$(stdlib_url_normalize "//example.com/foo/bar" --base "https://example.com")
assert "$stdout" == "https://example.com/foo/bar"

stdout=$(stdlib_url_normalize "//diff.com/foo/bar" --base "https://example.com")
assert "$stdout" == "http://diff.com/foo/bar"

stdout=$(stdlib_url_normalize "example.com/path" --base "different.com")
assert "$stdout" == "http://example.com/path"

stdlib_url_normalize -v out "https://example.com/path/?"
assert "$out" == "https://example.com/path"

stdout=$(stdlib_url_normalize "mailto:hello@website.com" --base "different.com")
assert "$stdout" == "mailto:hello@website.com"
