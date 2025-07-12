stdlib_import "json/query/jsonpath2jq"
stdlib_import "log"

stdlib_json_query() {
  printf -v sanitized_query "$@"
  local query_arg=${ stdlib_json_query_jsonpath2jq "$sanitized_query"; }

  stdlib_log_debug "jsonpath2jq ${sanitized_query@Q} => ${query_arg@Q}"

  jq --raw-output "$query_arg"
}
