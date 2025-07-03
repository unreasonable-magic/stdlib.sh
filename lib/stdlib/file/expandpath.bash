# This function takes a path and returns what it's full absolute version would
# be. So ~/foo becomes /Users/name/foo, and ./blah becomes "$(PWD)/blah".
#
# We could use realpath mostly for this, but that errors out if the path doesn't
# exist, which is kinda annoying to deal with, so this is just a slightly safer
# way of doing it without the headache of errors.
stdlib_file_expandpath() {
  local path="$1"
  local first_char="${path:0:1}"

  if [[ "$first_char" != "/" ]]; then
    if [[ "$first_char" == "~" ]]; then
      path="${HOME}${path:1}"
    else
      if [[ "$first_char" == "." ]]; then
        path="$(pwd)/${path::1}"
      else
        path="$(pwd)/$path"
      fi
    fi
  fi

  echo "$path"
}
