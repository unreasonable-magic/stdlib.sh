stdlib_import "error"
stdlib_import "string/hex"
stdlib_import "file/basename"

declare -g __stdlib_kvfs_keypath_return

stdlib_kvfs_keypath() {
  local return_arg
  if [[ "$1" == "--return" ]]; then
    return_arg="true"
    shift
  fi

  local store="$1"
  local key="$2"

  local encoded_key
  stdlib_string_hex_encode -v encoded_key "$key"

  local keypath="${store}/${encoded_key}"

  if [[ -n "$return_arg" ]]; then
    __stdlib_kvfs_keypath_return="${keypath}"
  else
    printf "%s\n" "${keypath}"
  fi
}

stdlib_kvfs_reset() {
  local -r store="$1"

  if [[ -e "${store}" ]]; then
    if ! rm -rf "${store}"; then
      stdlib_error_fatal "failed to remove ${store}, rm exited with $?"
    fi
  fi
}

stdlib_kvfs_delete() {
  stdlib_kvfs_keypath --return "$1" "$2"
  local -r keypath="$__stdlib_kvfs_keypath_return"

  if [[ -e "${keypath}" ]]; then
    if ! rm "${keypath}"; then
      stdlib_error_fatal "failed to remove ${store}, rm exited with $?"
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
      if ! mkdir -p "${store}"; then
        stdlib_error_log "can't create kfvs directory ${store} (exited with $?)"
        return 1
      fi
    fi
  fi

  local value="$3"
  echo "$value" > "$keypath"
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

  local -r value="$(<"$keypath")"

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
    local encoded_key
    encoded_key="$(stdlib_file_basename "$file")"

    local decoded_key
    stdlib_string_hex_decode -v decoded_key "$encoded_key"

    echo "$decoded_key"
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
      stdlib_kvfs_set "$store_name" "$@"
      ;;
    get)
      stdlib_kvfs_get "$store_name" "$@"
      ;;
    exists)
      stdlib_kvfs_exists "$store_name" "$@"
      ;;
    del|delete)
      stdlib_kvfs_delete "$store_name" "$@"
      ;;
    ls|list)
      stdlib_kvfs_list "$store_name" "$@"
      ;;
    --path)
      echo "$store_name"
      ;;
  esac
  '

  local function_code="
  $function_name() {
    local store_name=${store_path@Q}
    $command_handler_code
  }
  "

  eval "$function_code"
  "$function_name" "$@"
}
