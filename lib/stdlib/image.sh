stdlib_image_print() {
  local path="$1"
  local width="$2"
  local height="$3"

  if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
    "$STDLIB_PATH/contrib/iterm.sh" -W "${width}" -H "${height}" "$path"
  else
    encoded=$(echo "$path" | tr -d '\n' | base64 | tr -d '=' | tr -d '\n')

    if [[ "$width" == *px ]]; then
      width="${width/px/}"
      height="${height/px/}"
      printf "\e_Ga=T,q=2,f=100,t=f,s=$width,v=$height,C=1;%s\e\\" "$encoded"
    else
      printf "\e_Ga=T,q=2,f=100,t=f,c=$width,r=$height,C=1;%s\e\\" "$encoded"
    fi

  fi
}

stdlib_image_dimensions() {
  local -r path="$(realpath "$1")"

  if [[ "$path" == *.png ]]; then
    # This is extreemly not portable, but that's not a problem at the moment
    echo "$(/sbin/file "$path" | grep "PNG image" | awk '{print $5, $7}' | sed 's/,//g')"
  else
    echo "don't know how to handle $path yet"
    exit 1
  fi
}
