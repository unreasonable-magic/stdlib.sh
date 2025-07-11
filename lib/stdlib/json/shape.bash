stdlib_json_shape() {
  jq \
    --raw-output \
    -L "${STDLIB_PATH}/lib/stdlib/json/jq" \
    'include "shape"; . | shape'
}
