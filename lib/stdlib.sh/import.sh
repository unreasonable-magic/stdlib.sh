#!/usr/bin/env bash

stdlib::import() {
  local path="$STDLIB_PATH/lib/stdlib.sh"
  path="$path/$1"

  local filename="${1##*/}"

  # This is a bit of an obscure trick (that I wish was more readable).
  # It's a way of testing if a string has a substring inside it.
  #
  # What we need to know is, if the filename is missing an extenion,
  # we should try to come up with one. Because this function should be
  # as POSIX compatible as possible, we cant use regex or other fancy
  # expansion (except for what to see here).
  #
  # `${filename#*.}` is basically trying to replace everything after a
  # "." with a blank string. So "foo.bar" would become "foo.". We can
  # then tell if the substring exists by seeing if the newly updated
  # string with stuff maybe replaced is the same as the original
  if [ "${filename#*.}" == "$filename" ]; then
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
