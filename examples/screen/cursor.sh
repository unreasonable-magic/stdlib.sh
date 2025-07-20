eval "$(stdlib shellenv)"

cmd="visible=true blink=false style=underline"

run() {
  stdlib terminal/cursor $cmd
}

run

while read -p "> " -r input; do
  cmd="$input"
  run
done
