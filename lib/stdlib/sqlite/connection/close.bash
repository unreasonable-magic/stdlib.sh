stdlib_sqlite_close_connection() {
  local serialized_connection="$1"

  if stdlib_test string/is_empty "$serialized_connection"; then
    stdlib_error_log "missing connection"
    return 1
  fi

  kv -A conn -s '=' < <(printf "%s" "$serialized_connection")

  # pp connection
  # return

  # local read_fd="${}"
  # local write_fd="${}"
  # local pid="${conn["pid"]}"

  # Send .exit command to sqlite3 process
  echo ".exit" >&"${conn["write_fd"]}"

  # Close file descriptors
  exec {conn["write_fd"]} >&-
  exec {conn["read_fd"]} <&-

  # Wait for the coprocess to exit
  wait "${conn["pid"]}" 2>/dev/null

  # Remove the connection
  unset STDLIB_SQLITE_CONNECTIONS["${conn["pid"]}"]
  # unset 'SQLITE_CONNECTIONS_READ_FD["$connection_id"]'
  # unset 'SQLITE_CONNECTIONS_WRITE_FD["$connection_id"]'
  # unset 'SQLITE_CONNECTIONS_PID["$connection_id"]'
  # unset 'SQLITE_RECORD_SEPARATORS["$connection_id"]'

  stdlib_sqlite_log "info" "closed connection %q" "$serialized_connection"
}
