STDLIB_SQLITE_ROW=$'\036'
STDLIB_SQLITE_COL=$'\037'

stdlib::sqlite::logger::log() {
  mkdir -p "$HOME/.state/stdlib.sh/sqlite"
  echo -e "$1" >> "$HOME/.state/stdlib.sh/sqlite.log"
}

stdlib::sqlite::read() {
  while IFS= read -d $'\n' -r line <&"${sqlite_conn[0]}"; do
    if [[ "$line" == "" ]]; then
      break
    fi
    stdlib::sqlite::logger::log "$line"
    printf "%s\n" "$line"
  done

  stdlib::sqlite::logger::log "----"
}

stdlib::sqlite::connect() {
  coproc sqlite_conn (
    sqlite3 \
      -init "$STDLIB_PATH/lib/sqlite/initrc" \
      -interactive \
      "$1"
  )

  stdlib::sqlite::read > /dev/null

  stdlib::sqlite::logger::log "The print coprocess array: ${sqlite_conn[@]}"
  stdlib::sqlite::logger::log "The PID of the print coprocess is ${sqlite_conn_PID}"
}

stdlib::sqlite::execute() {
  for arg; do
    case "$arg" in
      --raw)
        shift
        ;;
    esac
  done

  stdlib::sqlite::logger::log "sql \e[1;32m$1\e[0m"

  echo "$1" >&"${sqlite_conn[1]}"

  IFS=$'\n' read -r prompt <&"${sqlite_conn[0]}"
  IFS=$'\n' read -r query <&"${sqlite_conn[0]}"

  stdlib::sqlite::logger::log "QUERY $query"

  stdlib::sqlite::read
}
