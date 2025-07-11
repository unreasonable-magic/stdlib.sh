stdlib_import "json/query/jsonpath2jq"

stdlib_json_query() {
  printf -v sanitized_query "$@"
  local query_arg=${ stdlib_json_query_jsonpath2jq "$sanitized_query"; }

  jq --raw-output "$query_arg"
}
