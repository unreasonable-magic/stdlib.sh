stdlib_import "error"
stdlib_import "maths/divide"
stdlib_import "maths/multiply"
stdlib_import "maths/round"
stdlib_import "log"

stdlib_animation_timer() {
  # Both duration and fps can be a floats so we can't use -i
  local duration_arg
  local fps=10
  local loop alternate reversed
  local debug_arg

  while [ $# -gt 0 ]; do
    arg="$1"
    shift

    case "$arg" in
    --duration)
      if [[ "$1" =~ ^([0-9]+\.?[0-9]*)([a-z]+)$ ]]; then
        local decimal="${BASH_REMATCH[1]}"
        case "${BASH_REMATCH[2]}" in
        s)
          duration_arg="$(stdlib_maths_multiply "$decimal" 1000)"
          ;;
        ms)
          duration_arg="$decimal"
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
        stdlib_error_log "invalid time: ${1@Q}"
        return 1
      fi
      shift
      ;;
    --fps)
      # Support complex (i.e. 100/11) frame rates, and simple ones (24, 30, etc)
      if [[ "$1" =~ ^([0-9]+)\/([0-9]+)$ ]]; then
        fps="$(stdlib_maths_divide "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}")"
      elif [[ "$1" =~ ^[0-9]+$ ]]; then
        fps="$1"
      else
        stdlib_error_log "invalid fps: ${1@Q}"
        return 1
      fi
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
    --debug)
      debug_arg="true"
      ;;
    *)
      stdlib_error_warning "unknown option $arg"
      shift
      return 1
      ;;
    esac
  done

  local -i first_frame=1

  local last_frame
  last_frame="$(stdlib_maths_divide "$(stdlib_maths_multiply "$fps" "$duration_arg")" 1000)"
  last_frame="$(stdlib_maths_round --ceil "${last_frame}")"
  declare -i last_frame

  local sleep_interval="$(stdlib_maths_divide "$(stdlib_maths_divide "$duration_arg" "$last_frame")" 1000)"

  if [[ "$reversed" == "true" ]]; then
    local -i frame="$last_frame"
    local direction="backwards"
  else
    local -i frame="$first_frame"
    local direction="forwards"
  fi

  [[ "$debug_arg" == "true" ]] && (
    stdlib_animation_timer_log_debug "---"
    stdlib_animation_timer_log_debug "duration=$duration_arg"
    stdlib_animation_timer_log_debug "fps=$fps"
    stdlib_animation_timer_log_debug "first_frame=$first_frame"
    stdlib_animation_timer_log_debug "last_frame=$last_frame"
    stdlib_animation_timer_log_debug "direction=$direction"
    stdlib_animation_timer_log_debug "---"
  )

  local playing="true"

  while [[ "$playing" == "true" ]]; do
    printf '%s\n' "$frame"

    [[ "$debug_arg" == "true" ]] &&
      stdlib_animation_timer_log_debug "frame=$frame"

    case "$direction" in

    forwards)
      if [[ "$frame" -ge "$last_frame" ]]; then
        if [[ "$loop" == "true" ]]; then
          if [[ "$alternate" == "true" ]]; then
            frame=$((last_frame - 1))
            direction="backwards"

            [[ "$debug_arg" == "true" ]] && (
              stdlib_animation_timer_log_debug "direction=$direction"
            )
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

            [[ "$debug_arg" == "true" ]] && (
              stdlib_animation_timer_log_debug "direction=$direction"
            )
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

    [[ "$debug_arg" == "true" ]] &&
      stdlib_animation_timer_log_debug "sleep_interval=$sleep_interval"

    sleep "$sleep_interval"
  done
}

stdlib_animation_timer_log_debug() {
  stdlib_log_debug "[animation/timer] $*"
}
