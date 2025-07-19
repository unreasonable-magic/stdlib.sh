stdlib_import "argparser"
stdlib_import "file/dirname"
stdlib_import "log"
stdlib_import "array/serialize"

STDLIB_SQLITE_DEFAULT_CONNECTION_DIR="$XDG_RUNTIME_DIR/stdlib.sh/sqlite/"

function stdlib_sqlite_connection {
  local path_arg="$1"
  shift

  if [[ -z "$path_arg" ]]; then
    stdlib_error_log "no path provided"
    return 1
  fi

  if ! mkdir -p "$STDLIB_SQLITE_DEFAULT_CONNECTION_DIR"; then
    stdlib_error_log "can't create %s" "$STDLIB_SQLITE_DEFAULT_CONNECTION_DIR"
    return 1
  fi

  coproc sqlite3_coproc {
    sqlite3 "$database_arg" 2>&1
  }

  # shellcheck disable=SC2181
  if [[ $? -ne 0 ]]; then
    stdlib_error_log "Failed to start sqlite3 coprocess"
    return 1
  fi

  local read_fd=""
  local write_fd=""
  local pid=""

  # Duplicate the coprocess file descriptors to new file descriptors
  exec {write_fd}>&"${sqlite3_coproc[1]}"
  exec {read_fd}<&"${sqlite3_coproc[0]}"

  # Close the original coprocess file descriptors
  # shellcheck disable=SC1083,SC2093
  exec {sqlite3_coproc[1]}>&-
  # shellcheck disable=SC1083,SC2093
  exec {sqlite3_coproc[0]}<&-

  # Get the coprocess PID
  pid=$!

  declare -A connection=(
    ["db"]="$path_arg"
    ["pid"]="$pid"
    ["read_fd"]="$read_fd"
    ["write_fd"]="$write_fd"
  )

  local serialized="${ stdlib_array_serialize -A connection; }"

  STDLIB_SQLITE_CONNECTIONS["$pid"]="$serialized"

  echo "$serialized" > "$STDLIB_SQLITE_DEFAULT_CONNECTION_DIR/$pid.pid"

  # stdlib_trapstack_add "stdlib_sqlite_close_all_connections"

  # stdlib_log_info "opened connection %s" "$serialized"

  printf "%s\n" "$pid"
}
