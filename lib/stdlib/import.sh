declare -g -A __stdlib_import_files=()

stdlib_import() {
  # If the path has already been loaded (or is being loaded) then we can just
  # return as a no-op
  if [[ "${__stdlib_import_files["$1"]}" != "" ]]; then
    return 0
  fi


  local path="$STDLIB_PATH/lib/stdlib"
  path="$path/$1"

  local filename="${1##*/}"

  # If no file extension was provided, try and figure one out (see
  # stdlib_string_contains for how this thing works)
  if [ "${filename#*"."}" == "$filename" ]; then
    local with_extension=""

    # If we're in bash, let's see if we can find a .bash version
    if [ -n "$BASH_VERSION" ]; then
      with_extension="${path}.bash"
      if [ -f "$with_extension" ]; then
        __stdlib_import_files["$1"]="$with_extension"
        source "$with_extension"
        return
      fi
    fi

    # Same with .zsh
    if [ -n "$ZSH_VERSION" ]; then
      with_extension="${path}.zsh"
      if [ -f "$with_extension" ]; then
        __stdlib_import_files["$1"]="$with_extension"
        source "$with_extension"
        return
      fi
    fi

    # Otherwise default to the regular .sh extension
    with_extension="${path}.sh"
    if [ -f "$with_extension" ]; then
      __stdlib_import_files["$1"]="$with_extension"
      source "$with_extension"
      return
    fi
  fi

  # If we've gotten this far, then the file might just work
  # if we try it, let's see...
  if [ -f "$path" ]; then
    __stdlib_import_files["$1"]="$path"
    if ! source "$path"; then
      stdlib_error_log "could not import $path"
      stdlib_error_stacktrace
      exit 1
    fi
  else
    stdlib_error_log "stdlib_import: no such file $path"
    exit 1
  fi
}
