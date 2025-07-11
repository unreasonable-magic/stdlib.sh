eval "$(stdlib shellenv)"

stdlib_import "json/query/jsonpath2jq"
stdlib_import "assert"

stdout=$(stdlib_json_query_jsonpath2jq "$.users[*].name")
assert "$stdout" == ".users[].name"

stdout=$(stdlib_json_query_jsonpath2jq "$.users[0].email")
assert "$stdout" == ".users[0].email"

stdout=$(stdlib_json_query_jsonpath2jq "$.users[?(@.age > 25)].name")
assert "$stdout" == ".users[] | select(.age > 25).name"

stdout=$(stdlib_json_query_jsonpath2jq "$..email")
assert "$stdout" == ".. | .email? // empty"

stdout=$(stdlib_json_query_jsonpath2jq "$.store.book[0].title")
assert "$stdout" == ".store.book[0].title"

stdout=$(stdlib_json_query_jsonpath2jq "$.store.book[*].author")
assert "$stdout" == ".store.book[].author"

stdout=$(stdlib_json_query_jsonpath2jq "$.users[0,2].name")
assert "$stdout" == ".users[0,2].name"

stdout=$(stdlib_json_query_jsonpath2jq "$.data.items[*].properties.id")
assert "$stdout" == ".data.items[].properties.id"

stdout=$(stdlib_json_query_jsonpath2jq "$.users[2:5]")
assert "$stdout" == ".users[2:5]"

stdout=$(stdlib_json_query_jsonpath2jq "$.users[?(@.status == 'active')]")
assert "$stdout" == ".users[] | select(.status == 'active')"
