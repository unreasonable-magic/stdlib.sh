stdlib_import "log"
stdlib_import "error"

declare -g __stdlib_kvfs_keypath_return

stdlib_kvfs_keypath() {
  local return_arg
  if [[ "$1" == "--return" ]]; then
    return_arg="true"
    shift
  fi

  local store="$1"
  local key="$2"

  local hash=0
  local i char

  for ((i=0; i < ${#key}; i++)); do
    char="${key:$i:1}"

    # Get ASCII value using printf
    printf -v ascii_val '%d' "'$char"
    hash=$(((hash * 31 + ascii_val) % 2147483647))
  done

  # Convert to positive if negative
  hash=$((hash < 0 ? -hash : hash))

  local hash_key
  printf -v hash_key '%d' "$hash"

  local keypath="${store}/${hash_key}"

  if [[ -n "$return_arg" ]]; then
    __stdlib_kvfs_keypath_return="${keypath}"
  else
    printf "%s\n" "${keypath}"
  fi
}

stdlib_kvfs_reset() {
  local -r store="$1"

  if [[ -e "${store}" ]]; then
    if rm -rf "${store}"; then
      stdlib_log_debug "reset ${store}"
    else
      stdlib_error_fatal "failed to remove ${store}, rm exited with $?"
    fi
  else
    stdlib_log_debug "store already reset ${store}"
  fi
}

stdlib_kvfs_delete() {
  stdlib_kvfs_keypath --return "$1" "$2"
  local -r keypath="$__stdlib_kvfs_keypath_return"

  if [[ -e "${keypath}" ]]; then
    if ! rm -rf "${keypath}"; then
      stdlib_error_fatal "failed to remove ${store}, rm -rf exited with $?"
    fi
  fi
}

stdlib_kvfs_set() {
  local store="$1"
  local key="$2"

  stdlib_kvfs_keypath --return "$store" "$key"
  local -r keypath="$__stdlib_kvfs_keypath_return"

  if [[ ! -d "$store" ]]; then
    if [[ -f "$store" ]]; then
      stdlib_error_log "${store} is a file, needs to be a directory"
      return 1
    else
      if mkdir -p "${store}"; then
        stdlib_log_debug "create kvfs ${store}"
      else
        stdlib_error_log "can't create kfvs directory ${store} (exited with $?)"
        return 1
      fi
    fi
  fi

  if ! mkdir -p "${keypath}"; then
    stdlib_error_log "can't create directory ${keypath} (exited with $?)"
    return 1
  fi

  echo "$key" > "$keypath/key"

  if [[ $# -lt 3 ]]; then
    if [[ -t 0 ]]; then
      stdlib_error_log "No value provided and no stdin available"
      return 1
    fi

    # direct data from stdin to the file
    cat > "$keypath/data"

    stdlib_log_debug "set ${keypath}/data=(…stdin…)"
  else
    printf '%s' "$3" > "$keypath/data"

    stdlib_log_debug "set ${keypath}/data=${3}"
  fi
}

stdlib_kvfs_exists() {
  stdlib_kvfs_keypath --return "$1" "$2"
  local -r keypath="$__stdlib_kvfs_keypath_return"

  [[ -e "$keypath" ]]
}

stdlib_kvfs_get() {
  local returnvar
  if [[ "$1" == "-v" ]]; then
    returnvar="$2"
    shift 2
  fi

  stdlib_kvfs_keypath --return "$1" "$2"
  local -r keypath="$__stdlib_kvfs_keypath_return"

  if [[ ! -e "$keypath" ]]; then
    return 1
  fi

  if [[ ! -r "$keypath" ]]; then
    return 1
  fi

  local -r value="$(<"$keypath/data")"

  if [[ -n "$returnvar" ]]; then
    declare -g __stdlib_kvfs_get_return="${value}"
    eval "$returnvar=\$__stdlib_kvfs_get_return"
    unset __stdlib_kvfs_get_return
  else
    printf "%s\n" "${value}"
  fi
}

stdlib_kvfs_list() {
  local -r store="$1"

  shopt -s nullglob
  shopt -s extglob

  for file in "$store"/*; do
    echo "$(<"$file/key")"
  done
}

stdlib_kvfs_create_proxy() {
  local function_name="$1"
  shift

  local store_path="$XDG_STATE_HOME/stdlib.sh/kv/$function_name"

  local command_handler_code='
  local command="$1"
  shift

  case "$command" in
    set)
      stdlib_kvfs_set "$store_path" "$@"
      ;;
    get)
      stdlib_kvfs_get "$store_path" "$@"
      ;;
    exists)
      stdlib_kvfs_exists "$store_path" "$@"
      ;;
    del|delete)
      stdlib_kvfs_delete "$store_path" "$@"
      ;;
    ls|list)
      stdlib_kvfs_list "$store_path" "$@"
      ;;
    reset)
      stdlib_kvfs_reset "$store_path" "$@"
      ;;
    --path)
      echo "$store_path"
      ;;
    *)
      stdlib_error_error "unknown kvfs proxy command $command"
      return 1
      ;;
  esac
  '

  local function_code="
  $function_name() {
    local store_path=${store_path@Q}
    $command_handler_code
  }
  "

  eval "$function_code"
  "$function_name" "$@"
}
