#!/usr/bin/env bash

stdlib::import() {
  local path="$STDLIB_PATH/lib/stdlib"
  path="$path/$1"

  local filename="${1##*/}"

  # If no file extension was provided, try and figure one out (see
  # string::contains for how this thing works)
  if [ "${filename#*"."}" == "$filename" ]; then
    local with_extension=""

    # If we're in bash, let's see if we can find a .bash version
    if [ -n "$BASH_VERSION" ]; then
      with_extension="${path}.bash"
      if [ -f "$with_extension" ]; then
        source "$with_extension"
        return
      fi
    fi

    # Same with .zsh
    if [ -n "$ZSH_VERSION" ]; then
      with_extension="${path}.zsh"
      if [ -f "$with_extension" ]; then
        source "$with_extension"
        return
      fi
    fi

    # Otherwise default to the regular .sh extension
    with_extension="${path}.sh"
    if [ -f "$with_extension" ]; then
      source "$with_extension"
      return
    fi
  fi

  # If we've gotten this far, then the file might just work
  # if we try it, let's see...
  if [ -e "$path" ]; then
    source "$path"
  else
    echo "stdlib::import: no such file $path" >&2
    exit 1
  fi
}
