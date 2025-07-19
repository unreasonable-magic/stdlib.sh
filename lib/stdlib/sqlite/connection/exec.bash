stdlib_sqlite_exec() {
  local connection="$1"
  local sql="$2"
  shift 2

  local read_timeout_arg="${STDLIB_SQLITE_DEFAULT_READ_TIMEOUT}"

  local callback=""
  local error_occurred=0

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
    --timeout)
      read_timeout_arg="$2"
      shift 2
      ;;
    *)
      stdlib_argparser error/invalid_arg "unknown argument: $1"
      return 1
      ;;
    esac
  done

  if stdlib_test string/is_empty "$connection"; then
    stdlib_error_log "missing connection"
    return 1
  fi

  if stdlib_test string/is_empty "$sql"; then
    stdlib_error_log "missing sql"
    return 1
  fi

  kv -A conn -s '=' < <(printf "%s" "$connection")

  local read_fd="${conn["read_fd"]}"
  local write_fd="${conn["write_fd"]}"
  local record_separator="${conn["record_separator"]}"

  if stdlib_test string/is_empty "$read_fd"; then
    stdlib_error_log "missing read_fd in $connection"
    return 1
  fi

  if stdlib_test string/is_empty "$write_fd"; then
    stdlib_error_log "missing write_fd in $connection"
    return 1
  fi

  # Determine mode and separator
  local sqlite_mode
  if [[ "$record_separator" == $'\t' ]]; then
    sqlite_mode="tcl"
  else
    sqlite_mode="list"
  fi

  stdlib_sqlite_log "info" "$sql"

  # Send the SQL command to the sqlite3 process
  {
    echo ".headers on"
    echo ".mode csv"
    # echo ".separator '$record_separator'"
    echo "$sql;"
    echo ".headers off"
    echo ".mode list"
    echo "SELECT 'END-OF-QUERY';"
  } >&"${write_fd}"

  # Read output until 'END-OF-QUERY' is encountered
  local line=""

  local -a headers=()
  while true; do
    if ! IFS=$'\n\r' read -r -t "$read_timeout_arg" -u "${read_fd}" line; then
      # If read fails or times out
      stdlib_sqlite_log "error" "failed to read from process for connection %q" "$connection"
      error_occurred=1
      # if [[ -n "$SQLITE_ERROR_CALLBACK" ]]; then
      #   "$SQLITE_ERROR_CALLBACK" "Read timeout or failure on connection $connection_id" 1
      # fi
      break
    fi

    # First line is always the header
    if [[ "${#headers}" -eq 0 ]]; then
      dsv -a headers "$line"

      pp headers

      continue
    fi

    if [[ "$line" == "END-OF-QUERY" ]]; then
      break
    elif [[ "$line" == "Error: "* ]]; then
      stdlib_sqlite_log "error" "error on connection %q %q" "$connection" "$line"
      error_occurred=1
      # if [[ -n "$SQLITE_ERROR_CALLBACK" ]]; then
      #   "$SQLITE_ERROR_CALLBACK" "$line" 1
      # fi
      break
    else
      local -a row=()
      local -i index=0
      dsv -p -a row "$line"

      for column in "${headers[@]}"; do
        printf '%s=%s ' "${headers[$index]}" "${row[$index]}"
        index+=1
      done
      printf "\n"
    fi
  done

  if [[ "$error_occurred" -ne 0 ]]; then
    return 1
  fi
}
