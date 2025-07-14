stdlib_json_schema_generate() {
  jq \
    --raw-output \
    -L "${STDLIB_PATH}/lib/stdlib/json/jq" \
    'include "to_schema"; . | to_schema'
}
