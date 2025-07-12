stdlib_import "string/dedent"

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
  " | stdlib_string_dedent >>"lib/stdlib/ui/spinner/data/${1}.txt"

  cat contrib/spinners.json | jq -r ".$1.frames[]" >>"lib/stdlib/ui/spinner/data/${1}.txt"
}

export -f spinner_to_txt

rm -rf lib/stdlib/ui/spinner/data
mkdir -p lib/stdlib/ui/spinner/data

cat contrib/spinners.json | jq 'keys[] | @text' -r | xargs -I {} bash -c "spinner_to_txt {}"

# echo '---' >> lib/stdlib/ui/spinner/data/{}.txt; echo 'interval=' >> lib/stdlib/ui/spinner/data/{}.txt; echo '---' >> lib/stdlib/ui/spinner/data/{}.txt"
