#!/usr/bin/env bash

eval "$(stdlib shellenv)"

stdlib_import "animation/timer"

select example in simple loop reversed alternate speed; do
  case "$example" in
  simple)
    stdlib_animation_timer --duration 1000ms
    ;;
  loop)
    stdlib_animation_timer --duration 1000ms --loop
    ;;
  reversed)
    stdlib_animation_timer --duration 1000ms --reversed
    ;;
  alternate)
    stdlib_animation_timer --duration 1000ms --loop --alternate
    ;;
  speed)
    stdlib_animation_timer --duration 1000ms --loop --alternate --fps 60
    ;;
  esac
  exit_status=$?
  if [[ ! $exit_status -eq 0 ]]; then
    exit $exit_status
  fi
  break
done
