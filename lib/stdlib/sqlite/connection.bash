stdlib_import "array/serialize"
stdlib_import "trapstack"

enable dsv

# Functions in here were originally inspired by
# https://github.com/ngirard/sqlite-shell-lib, but have since been heavily
# modified to work in stdlib.

# function log {
#     local date_format="${BASHLOG_DATE_FORMAT:-+%F %T}"
#     local date_s
#     local level="$1"
#     local upper_level="${level^^}"
#     local debug_level="${DEBUG:-0}"
#     local message
#     local severity
#
#     shift
#     date_s=$(date "+%s")
#     message=$(printf "%s" "$@")
#
#     # Severity levels
#     local -A severities=( [DEBUG]=7 [INFO]=6 [WARN]=4 [ERROR]=3 )
#     severity=${severities[$upper_level]:-3}
#
#     # Log the message based on the debug level and severity
#     if (( debug_level > 0 )) || [ "$severity" -lt 7 ]; then
#         if [[ "${BASHLOG_SYSLOG:-0}" -eq 1 ]]; then
#             log_to_syslog "$date_s" "$upper_level" "$message" "$severity"
#         else
#             log_to_console "$date_format" "$upper_level" "$message"
#         fi
#     fi
# }
#
# # Sends log messages to the syslog service with appropriate metadata.
# function log_to_syslog {
#     local date_s="$1"
#     local upper_level="$2"
#     local message="$3"
#     local severity="$4"
#     local facility="${BASHLOG_SYSLOG_FACILITY:-user}"
#
#     logger --id=$$ \
#            --tag "${PROGRAM}" \
#            --priority "${facility}.$severity" \
#            "$message" \
#       || _log_exception "logger --id=$$ -t ... \"$upper_level: $message\""
# }
#
# # Logs messages to the console, with optional JSON formatting.
# function log_to_console {
#     local date_format="$1"
#     local upper_level="$2"
#     local message="$3"
#     local date
#     local console_line
#     local colour
#
#     date=$(date "$date_format")
#
#     # Define color codes
#     local -A colours=( [DEBUG]='\033[34m' [INFO]='\033[32m' [WARN]='\033[33m' [ERROR]='\033[31m' [DEFAULT]='\033[0m' )
#     colour="${colours[$upper_level]:-\033[31m}"
#
#     if [ "${BASHLOG_JSON:-0}" -eq 1 ]; then
#         console_line=$(printf '{"timestamp":"%s","level":"%s","message":"%s"}' "$date_s" "$upper_level" "$message")
#         printf "%s\n" "$console_line" >&2
#     else
#         console_line="${colour}$date [$upper_level] $message${colours[DEFAULT]}"
#         printf "%b\n" "$console_line" >&2
#     fi
# }
#
# function _log_exception {
#     local log_cmd="$1"
#     log "error" "Logging Exception: ${log_cmd}"
# }
#
# # Immediately exits the script after logging a fatal error message.
# function fatal {
#     log error "$@"
#     exit 1
# }
#
# export -f log log_to_syslog log_to_console _log_exception fatal
#
# # --- End of Logging Functions ---
#
# # --- Bash Version Check ---
# if [[ "${BASH_VERSINFO:-0}" -lt 4 ]]; then
#     fatal "Error: Bash version 4 or higher is required." >&2
# fi
#
# # Global Variables
#
declare -A STDLIB_SQLITE_CONNECTIONS
STDLIB_SQLITE_LAST_QUERY_COLUMNS=""
# declare -A SQLITE_CONNECTIONS_READ_FD   # Stores read file descriptors per connection
# declare -A SQLITE_CONNECTIONS_WRITE_FD  # Stores write file descriptors per connection
# declare -A SQLITE_CONNECTIONS_PID       # Stores PIDs per connection
# declare -A SQLITE_RECORD_SEPARATORS     # Stores record separators per connection
# declare SQLITE_GLOBAL_RECORD_SEPARATOR=$'\t'  # Default global record separator
# declare SQLITE_ERROR_CALLBACK=""        # User-defined error handling callback
STDLIB_SQLITE_DEFAULT_READ_TIMEOUT=5 # Timeout in seconds for reading from coprocess
# declare SQLITE_LAST_CONNECTION_ID=""    # Holds the last connection ID
#
# # Trap to ensure connections are closed upon script exit
# trap 'sqlite_cleanup_all_connections' EXIT
#
# # Registers a user-defined error handling callback function.
# function sqlite_register_error_callback {
#     local callback_function=""
#
#     # Parse arguments
#     while [[ $# -gt 0 ]]; do
#         case "$1" in
#             --callback)
#                 callback_function="$2"
#                 shift 2
#                 ;;
#             *)
#                 fatal "Unknown argument: $1"
#                 ;;
#         esac
#     done
#
#     if [[ -z "$callback_function" ]]; then
#         fatal "Error callback function name must be provided with --callback"
#     fi
#
#     SQLITE_ERROR_CALLBACK="$callback_function"
#     log "info" "Registered error callback: $SQLITE_ERROR_CALLBACK"
# }
#
# # Sets the global record separator.
# function sqlite_set_global_record_separator {
#     local separator=""
#
#     # Parse arguments
#     while [[ $# -gt 0 ]]; do
#         case "$1" in
#             --separator)
#                 separator="$2"
#                 shift 2
#                 ;;
#             *)
#                 fatal "Unknown argument: $1"
#                 ;;
#         esac
#     done
#
#     SQLITE_GLOBAL_RECORD_SEPARATOR="$separator"
#     log "info" "Global record separator set to: $separator"
# }
#
# # Sets the read timeout for SQLite queries.
# function sqlite_set_read_timeout {
#     local timeout=""
#
#     # Parse arguments
#     while [[ $# -gt 0 ]]; do
#         case "$1" in
#             --timeout)
#                 timeout="$2"
#                 shift 2
#                 ;;
#             *)
#                 fatal "Unknown argument: $1"
#                 ;;
#         esac
#     done
#
#     if ! [[ "$timeout" =~ ^[0-9]+$ ]]; then
#         fatal "Invalid timeout value: $timeout"
#     fi
#
#     SQLITE_READ_TIMEOUT="$timeout"
#     log "info" "Read timeout set to: $timeout seconds"
# }
# Opens a connection to a SQLite database.

# declare -A STDLIB_SQLITE_CONNECTION

stdlib_sqlite_log() {
  local level="$1"
  local message="$2"
  shift 2

  printf -v formatted "$message" "$@"

  "stdlib_log_$level" "sqlite: $formatted"
}

stdlib_sqlite_close_all_connections() {
  local signal="$1"

  if [[ "$signal" == EXIT ]]; then
    local id

    for id in "${!STDLIB_SQLITE_CONNECTIONS[@]}"; do
      local connection="${STDLIB_SQLITE_CONNECTIONS["$id"]}"

      # If the connection has already been closed the array item/key will still
      # be there, just the value gone.
      if stdlib_test string/is_present "$connection"; then
        stdlib_sqlite_close_connection "${STDLIB_SQLITE_CONNECTIONS["$id"]}"
      fi
    done

    stdlib_sqlite_log "debug" "closed all connections"
  fi
}

stdlib_sqlite_parse_row() {
  local row="$1"
}

#
# # Begins a transaction on a given connection.
# function sqlite_begin_transaction {
#     local connection_id=""
#
#     # Parse arguments
#     while [[ $# -gt 0 ]]; do
#         case "$1" in
#             --connection-id)
#                 connection_id="$2"
#                 shift 2
#                 ;;
#             *)
#                 fatal "Unknown argument: $1"
#                 ;;
#         esac
#     done
#
#     sqlite_query --connection-id "$connection_id" --query "BEGIN TRANSACTION;"
# }
#
# # Commits a transaction on a given connection.
# function sqlite_commit_transaction {
#     local connection_id=""
#
#     # Parse arguments
#     while [[ $# -gt 0 ]]; do
#         case "$1" in
#             --connection-id)
#                 connection_id="$2"
#                 shift 2
#                 ;;
#             *)
#                 fatal "Unknown argument: $1"
#                 ;;
#         esac
#     done
#
#     sqlite_query --connection-id "$connection_id" --query "COMMIT;"
# }
#
# # Rolls back a transaction on a given connection.
# function sqlite_rollback_transaction {
#     local connection_id=""
#
#     # Parse arguments
#     while [[ $# -gt 0 ]]; do
#         case "$1" in
#             --connection-id)
#                 connection_id="$2"
#                 shift 2
#                 ;;
#             *)
#                 fatal "Unknown argument: $1"
#                 ;;
#         esac
#     done
#
#     sqlite_query --connection-id "$connection_id" --query "ROLLBACK;"
# }
#
#
# # Lists all active connections.
# function sqlite_list_connections {
#     echo "Active SQLite connections:"
#     for connection_id in "${!SQLITE_CONNECTIONS_PID[@]}"; do
#         echo " - $connection_id"
#     done
# }
#
# # Export library functions
# export -f sqlite_register_error_callback
# export -f sqlite_set_global_record_separator
# export -f sqlite_set_read_timeout
# export -f sqlite_open_connection
# export -f sqlite_close_connection
# export -f sqlite_query
# export -f sqlite_begin_transaction
# export -f sqlite_commit_transaction
# export -f sqlite_rollback_transaction
# export -f sqlite_cleanup_all_connections
# export -f sqlite_list_connections
#
# # End of Bash SQLite Library
