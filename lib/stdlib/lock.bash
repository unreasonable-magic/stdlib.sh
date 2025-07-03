stdlib_import "log"

DEFAULT_LOCK_DIR="$XDG_RUNTIME_DIR/stdlib.sh/locks/"

stdlib_lock_acquire() {
  local -r name="$1"

  log_debug "Waiting on lock $name"

  while true; do
    if [ ! -d "$DEFAULT_LOCK_DIR" ]; then
      if ! mkdir -p "$DEFAULT_LOCK_DIR"; then
        stdlib_log_warn "Failed to create lock directory: $DEFAULT_LOCK_DIR"
        return 1
      fi
    fi

    local lock_path="${DEFAULT_LOCK_DIR}/${1}.lock"

    if (set -o noclobber; echo "$$" > "$lock_path") 2> /dev/null; then
      log_debug "Created $name lock."
      break
    else
      # Grab the pid from the lock and see if the process is still alive. If
      # it's gone, we can safely remove the lock and try again
      local lock_owner_pid
      lock_owner_pid="$(<"$lock_path")"

      if ! kill -0 "$lock_owner_pid" 2>/dev/null; then
        echo "Process $PID is not running"
        log_warn "Removing lock $name as pid $lock_owner_pid is gone"
        stdlib_lock_release "$name"
        continue
      fi

      sleep 1
    fi
  done
}

stdlib_lock_release() {
  log_debug "Releasing lock: $1"

  local -r lock_path="$DEFAULT_LOCK_DIR/${1}.lock"

  if ! rm "$lock_path"; then
    log_warn "Failed to remove lock: $lock_path"
  fi
}

stdlib_lock_create_proxy() {
  local function_name="$1"
  shift

  local command_handler_code='
  local command="$1"
  shift

  case "$command" in
    acquire)
      stdlib_lock_acquire "$lock_name" "$@"
      ;;
    release)
      stdlib_lock_release "$lock_name" "$@"
      ;;
    --path)
      echo "$DEFAULT_LOCK_DIR/${lock_name}.lock"
      ;;
  esac
  '

  local function_code="
  $function_name() {
    local lock_name=${function_name@Q}
    $command_handler_code
  }
  "

  eval "$function_code"
  "$function_name" "$@"
}
