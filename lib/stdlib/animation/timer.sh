stdlib_import "error"
stdlib_import "maths/divide"

stdlib_animation_timer() {
  local -i duration
  local -i fps=10
  local loop alternate reversed

  while [ $# -gt 0 ]; do
    arg="$1"
    shift

    case "$arg" in
    --duration)
      if [[ "$1" =~ ^([0-9]+)(.*)$ ]]; then
        local -i num="${BASH_REMATCH[1]}"
        case "${BASH_REMATCH[2]}" in
        s)
          duration=$((num * 1000))
          ;;
        ms)
          duration=$num
          ;;
        '')
          stdlib_error_log "missing precison for time (s or ms): $1"
          return 1
          ;;
        *)
          stdlib_error_log "invalid precison for time: $1"
          return 1
          ;;
        esac
      else
        stdlib_error_log "invalid time format for duration: $1"
        return 1
      fi
      shift
      ;;
    --fps)
      fps="$1"
      shift
      ;;
    --loop)
      loop="true"
      ;;
    --reversed)
      reversed="true"
      ;;
    --alternate)
      alternate="true"
      ;;
    *)
      echo "unknonw option $arg"
      shift
      ;;
    esac
  done

  local -i first_frame=1
  local -i last_frame="$(stdlib_maths_divide "$((fps * duration))" 1000)"

  local sleep_duration="$(stdlib_maths_divide "$(stdlib_maths_divide "$duration" "$last_frame")" 1000)"

  if [[ "$reversed" == "true" ]]; then
    local -i frame="$last_frame"
    local direction="backwards"
  else
    local -i frame="$first_frame"
    local direction="forwards"
  fi

  local playing="true"

  while [[ "$playing" == "true" ]]; do
    printf '%s\n' "$frame"

    case "$direction" in

    forwards)
      if [[ "$frame" -ge "$last_frame" ]]; then
        if [[ "$loop" == "true" ]]; then
          if [[ "$alternate" == "true" ]]; then
            frame=$((last_frame - 1))
            direction="backwards"
          else
            frame="$first_frame"
          fi
        else
          playing="false"
        fi
      else
        frame=$((frame + 1))
      fi
      ;;

    backwards)
      if [[ "$frame" -le "$first_frame" ]]; then
        if [[ "$loop" == "true" ]]; then
          if [[ "$alternate" == "true" ]]; then
            frame=$((first_frame + 1))
            direction="forwards"
          else
            frame="$last_frame"
          fi
        else
          playing="false"
        fi
      else
        frame=$((frame - 1))
      fi
      ;;

    esac

    sleep "$sleep_duration"
  done
}
