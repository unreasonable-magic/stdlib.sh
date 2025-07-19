stdlib_import "json/schema/infer"
stdlib_import "json/flatten"
stdlib_import "string/underscore"
stdlib_import "string/pluralize"
stdlib_import "string/dequote"
stdlib_import "string/indent"
stdlib_import "array/join"
# stdlib_import "sqlite/exec"
stdlib_import "sqlite/connection"
stdlib_import "test"

enable kv

stdlib_sqlite_import_json_create_table_sql() {
  local table_name="$1"
  declare -n schema_ref="${2}"

  local -a columns=()

  for key in "${!schema_ref[@]}"; do
    value="${schema_ref[$key]}"

    if [[ "$key" =~ ^\$\.properties.([^.]+)$ ]]; then
      local name="${BASH_REMATCH[1]}"
      local type="${schema_ref["${key}.type"]}"

      local column_name="${
        stdlib_string_underscore "$name";
      }"

      local column_type
      case "$type" in
        '"string"')
          column_type="TEXT"
          ;;
        *)
          column_type="TEXT"
          ;;
      esac

      local primary_key=""
      if [[ "$name" == "id" ]]; then
        primary_key=" PRIMARY KEY"
      fi

      columns+=("${column_name} ${column_type}${primary_key}")
    fi
  done

  printf "CREATE TABLE IF NOT EXISTS %s (\n%s\n);\n" \
    "$table_name" \
    "${ stdlib_array_join -a columns -d $',\n'; }"
}

stdlib_sqlite_import_json_insert_records_sql() {
  local table_name="$1"
  local json_file="$2"
  declare -n schema_ref="${3}"

  local -a insert_columns=()
  local -a select_columns=()

  for key in "${!schema_ref[@]}"; do
    value="${schema_ref[$key]}"

    if [[ "$key" =~ ^\$\.properties.([^.]+)$ ]]; then
      local name="${BASH_REMATCH[1]}"
      local column_name="${ stdlib_string_underscore "$name"; }"

      insert_columns+=("  $column_name")
      select_columns+=("  json_extract(value, '$.$name') as $column_name")

    fi
  done

  printf "INSERT OR IGNORE INTO %s (\n%s\n)\nSELECT\n%s\nFROM\n  json_each(readfile('%s')) RETURNING changes();\n" \
    "$table_name" \
    "${ stdlib_array_join -a insert_columns -d $',\n'; }" \
    "${ stdlib_array_join -a select_columns -d $',\n'; }" \
    "$json_file"

    # printf "WITH json_data AS (SELECT readfile('%s') as json_content) SELECT\n%s\nFROM\n  json_data;\n" \
    # "$json_file" \
    # "${ stdlib_array_join -a select_columns -d $',\n'; }"
}

stdlib_sqlite_import_json() {
  local db="$1"
  if stdlib_test string/is_empty "$1"; then
    stdlib_argparser error/length_mismatch 1
    return 1
  fi

  local table_name="$2"

  local stdin_tmp="${ mktemp; }"
  cat > "$stdin_tmp"

  local root_type=""
  case $(grep -o '[^[:space:]]' "$stdin_tmp" | head -1) in
    '[') root_type="array" ;;
    '{') root_type="object" ;;
    *) echo "invalid json" ;;
  esac

  local schema_str=""
  if [[ "$root_type" == "object" ]]; then
    schema_str="${ cat "$stdin_tmp" | stdlib_json_schema_infer | stdlib_json_flatten; }"
  else
    schema_str="${ cat "$stdin_tmp" | stdlib json/query '$.[0]' | stdlib_json_schema_infer | stdlib_json_flatten; }"
  fi

  declare -A schema
  kv -A schema -s "=" < <(echo "$schema_str")

  if [[ "$table_name" == "" ]]; then
    local schema_title="${ stdlib_string_dequote "${schema["$.title"]}"; }"
    table_name="${ stdlib_string_pluralize "${schema_title}"; }"
  fi

  local connection="${ stdlib_sqlite_connection_open "test/fixtures/northwind.db"; }"

  # pp connection

  # local sql="${ stdlib_sqlite_import_json_create_table_sql "$table_name" schema; }"
  local sql="select * from orders limit 10";

  # IFS=
  # for row in stdlib_sqlite_exec "$connection" "$sql"; do
  #   echo "ROW: ${row}"
  # done
  echo "$$"

  to_newlines_printf() {
    local input="$1"

    # Replace curly quotes with straight quotes
    #input="${input//"/\"}"
    #input="${input//"/\"}"

    echo "bb"
    printf "IFS is: [%q]\n" "$IFS"
    set | grep -E '^(noglob|nounset|errexit)'
    # echo "$input" | od -c | grep '"'
    echo "bb"

    # Remove any carriage returns or other weird characters
    input="${input//$'\r'/}"

    set -f; set -- $input; set +f

    local counter=1
    for arg in "$@"; do
      # echo "[$counter]: [$arg]"
      ((counter++))
    done

    # printf '%s\n' "$@"
}

  while read -r row; do

    #pp row
    #local str=""
    # string="apple banana cherry orange"
    #for col in $row; do
  #pp row
    to_newlines_printf "$row"
    #pp blah
    #done
    # pp row
    # kv -s "=" -d ' | ' <<< "${row}"
    # pp KV
    # pp row
    # dsv "$row"
    # pp DSV
    # printf "RRRRRR %s" "${row[@]}"
  done <<< "${ stdlib_sqlite_exec "$connection" "$sql"; }"

  # stdlib_sqlite_import_json_create_table_sql "$table_name" schema | tee sql.log | sqlite3 "$db"
  # echo "$?"
  # stdlib_sqlite_import_json_insert_records_sql "$table_name" "$stdin_tmp" schema | tee sql.log | sqlite3 "$db"
}
