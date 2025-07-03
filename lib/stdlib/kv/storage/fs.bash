stdlib::import "file/dirname"
stdlib::import "file/basename"
stdlib::import "error"

stdlib_kv_storage_fs_path() {
  if [[ -z "$1" ]]; then
    stdlib::error::fatal "missing kv store name"
  fi

  echo "${XDG_STATE_HOME}/stdlib.sh/kv/${1}"
}


stdlib_kv_storage_fs_delete() {
  local -r path="$(stdlib_kv_storage_fs_path "$1")"

  if [[ -e "${path}" ]]; then
    if ! rm -rf "${path}"; then
      stdlib::error::fatal "failed to remove ${path}, rm exited with $?"
    fi
  fi
}

stdlib_kv_storage_fs_set() {
  local -r path="$(stdlib_kv_storage_fs_path "$1")"
  local -r dir="$(dirname "$path")"

  if [[ -d "$path" ]]; then
    stdlib::error::log "${1} collides with an existing key"
    return 1
  fi

  if ! mkdir -p "${dir}"; then
    stdlib::error::fatal "set $1 failed. can't create directory ${dir} (exited with $?)"
  fi

  echo "$2" > "$path"
}

stdlib_kv_storage_fs_exists() {
  local -r path="$(stdlib_kv_storage_fs_path "$1")"

  [[ -e "$path" ]]
}

stdlib_kv_storage_fs_get() {
  local -r path="$(stdlib_kv_storage_fs_path "$1")"

  if [[ ! -e "$path" ]]; then
    stdlib::error::log "$1 doesn't exist"
    return 1
  fi

  if [[ ! -r "$path" ]]; then
    stdlib::error::log "$1 is not readable"
    return 1
  fi

  cat "$path"
}

stdlib_kv_storage_fs_list() {
  local -r path="$(stdlib_kv_storage_fs_path "$1")"

  shopt -s nullglob
  shopt -s extglob

  for file in $path; do
    echo "$file"
  done
}
