STDLIB_SQLITE_ROW=$'\036'
STDLIB_SQLITE_COL=$'\037'

stdlib_sqlite_logger_log() {
  mkdir -p "$HOME/.state/stdlib.sh/sqlite"
  echo -e "$1" >>"$HOME/.state/stdlib.sh/sqlite.log"
}

stdlib_sqlite_read() {
  while IFS= read -d $'\n' -r line <&"${sqlite_conn[0]}"; do
    if [[ "$line" == "" ]]; then
      break
    fi
    stdlib_sqlite_logger_log "$line"
    printf "%s\n" "$line"
  done

  stdlib_sqlite_logger_log "----"
}

stdlib_sqlite_connect() {
  coproc sqlite_conn (
    sqlite3 \
      -init "$STDLIB_PATH/lib/sqlite/initrc" \
      -interactive \
      "$1"
  )

  stdlib_sqlite_read >/dev/null

  stdlib_sqlite_logger_log "The print coprocess array: ${sqlite_conn[@]}"
  stdlib_sqlite_logger_log "The PID of the print coprocess is ${sqlite_conn_PID}"
}

stdlib_sqlite_execute() {
  for arg; do
    case "$arg" in
    --raw)
      shift
      ;;
    esac
  done

  stdlib_sqlite_logger_log "sql \e[1;32m$1\e[0m"

  echo "$1" >&"${sqlite_conn[1]}"

  IFS=$'\n' read -r prompt <&"${sqlite_conn[0]}"
  IFS=$'\n' read -r query <&"${sqlite_conn[0]}"

  stdlib_sqlite_logger_log "QUERY $query"

  stdlib_sqlite_read
}
