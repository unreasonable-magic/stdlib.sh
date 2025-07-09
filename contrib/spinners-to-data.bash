
dedent() {
    local lines=()
    local line
    local indent_to_remove=0
    local found_first_text=false
    local i

    # Read all lines into array
    while IFS= read -r line; do
        lines+=("$line")
    done

    # Remove empty lines from the beginning
    while [[ ${#lines[@]} -gt 0 && ( -z "${lines[0]}" || "${lines[0]}" =~ ^[[:space:]]*$ ) ]]; do
        lines=("${lines[@]:1}")  # Remove first element
    done

    # Remove empty lines from the end
    while [[ ${#lines[@]} -gt 0 && ( -z "${lines[-1]}" || "${lines[-1]}" =~ ^[[:space:]]*$ ) ]]; do
        unset 'lines[-1]'  # Remove last element
    done

    # Find indent amount from first non-empty line
    if [[ ${#lines[@]} -gt 0 ]]; then
        local first_line="${lines[0]}"
        # Count leading spaces
        indent_to_remove=0
        while [[ $indent_to_remove -lt ${#first_line} && "${first_line:$indent_to_remove:1}" == " " ]]; do
            ((indent_to_remove++))
        done
    fi

    # Remove the indent from each line
    for line in "${lines[@]}"; do
        # For empty lines, just print them
        if [[ -z "$line" || "$line" =~ ^[[:space:]]*$ ]]; then
            printf '%s\n' "$line"
        else
            # Remove indent_to_remove spaces from the beginning
            if [[ $indent_to_remove -gt 0 && ${#line} -ge $indent_to_remove ]]; then
                printf '%s\n' "${line:$indent_to_remove}"
            else
                printf '%s\n' "$line"
            fi
        fi
    done
}

export -f dedent

spinner_to_txt() {
  # echo "$1"
  # cat contrib/spinners.json | jq 'keys[] | @text' -r | xargs -I {} bash -c "spinner_to_txt {}"
  #
  local interval="" width=""

  eval "$(cat contrib/spinners.json | jq -r "@sh \"width=\(.$1.width) interval=\(.$1.interval) frame_count=\((.$1.frames | length))\"")"

  echo "
  ---
  interval=$interval
  width=$width
  frame_count=$frame_count
  ---
  " | dedent >> "lib/stdlib/ui/spinner/data/${1}.txt"

  cat contrib/spinners.json | jq -r ".$1.frames[]" >> "lib/stdlib/ui/spinner/data/${1}.txt"
}

export -f spinner_to_txt

rm -rf lib/stdlib/ui/spinner/data
mkdir -p lib/stdlib/ui/spinner/data

cat contrib/spinners.json | jq 'keys[] | @text' -r | xargs -I {} bash -c "spinner_to_txt {}"

# echo '---' >> lib/stdlib/ui/spinner/data/{}.txt; echo 'interval=' >> lib/stdlib/ui/spinner/data/{}.txt; echo '---' >> lib/stdlib/ui/spinner/data/{}.txt"
