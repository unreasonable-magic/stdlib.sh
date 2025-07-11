stdlib_json_join() {
  local -a filenames=()

  # Check if we have arguments
  if [[ $# -gt 0 ]]; then
    # Called with arguments: stdlib_json_join my/folder/*.json
    filenames=("$@")
  else
    # Called without arguments, read from stdin: ls my/folder/*.json | stdlib_json_join
    while IFS= read -r line; do
      filenames+=("$line")
    done
  fi

  # Check if we have any files to process
  if [[ ${#filenames[@]} -eq 0 ]]; then
    stdlib_error_log "No files provided"
    return 1
  fi

  jq -n '
  reduce inputs as $item ({};
  . + {(input_filename | split("/")[-1] | split(".")[0]): $item}
  )' "${filenames[@]}"
}
