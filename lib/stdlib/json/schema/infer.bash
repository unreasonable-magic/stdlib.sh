stdlib_json_schema_infer() {
  local title_arg=""

  while [ $# -gt 0 ]; do
    case "$1" in
      --title)
        local title_arg="$2"
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
    --arg "TITLE" "$title_arg" \
    'include "infer"; . | infer(true)'
}
