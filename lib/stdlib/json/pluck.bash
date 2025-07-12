stdlib_import "json/query/jsonpath2jq"
stdlib_import "array/join"

stdlib_json_pluck() {
  # printf -v sanitized_query "$@"
  # local query_arg=${ stdlib_json_query_jsonpath2jq "$sanitized_query"; }

  local -a paths=()
  for arg in "$@"; do
    paths+=(".$arg // \"\"")
  done

  local query="${ stdlib_array_join --delim "," -a paths; }"

  jq --compact-output --raw-output "$query"
}
