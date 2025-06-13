#!/usr/bin/env bash

stdlib::import "error"
stdlib::import "maths/divide"

timer() {
  local duration
  local loop alternate reversed
  local fps="10"

  while [ $# -gt 0 ]; do
    arg="$1"
    shift

    case "$arg" in
      --duration)
        duration="$1"
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
  local -i last_frame="$(divide "$((fps * duration))" 1000)"

  local sleep_duration="$(divide "$(divide "$duration" "$last_frame")" 1000)"

  if [[ "$reversed" == "true" ]]; then
    local -i frame="$last_frame"
    local direction="backwards"
  else
    local -i frame="$first_frame"
    local direction="forwards"
  fi

  local playing="true"

  while [[ "$playing" == "true" ]]; do
    echo "$frame"
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
