stdlib_import "argparser"
stdlib_import "json/query/jsonpath2jq"

stdlib_json_flatten() {
  local query_arg="."
  local prefix_arg=""

  while [ $# -gt 0 ]; do
    case "$1" in
      --prefix)
        local prefix_arg="$2"
        shift 2
        ;;
      --query)
        query_arg=${ stdlib_json_query_jsonpath2jq "$2"; }
        shift 2
        ;;
      *)
        stdlib_argparser error/invalid_arg "$@"
        return 1
        ;;
    esac
  done

  jq \
    --raw-output \
    -L "${STDLIB_PATH}/lib/stdlib/json/jq" \
    --arg "PREFIX" "$prefix_arg" \
    "include \"flatten\"; $query_arg | flatten(\$PREFIX)"
  }
