#!/usr/bin/env bash

eval "$(stdlib shellenv)"

stdlib_import "animation/timer"

select example in simple loop reversed alternate speed; do
  case "$example" in
  simple)
    stdlib_animation_timer --duration 1000
    ;;
  loop)
    stdlib_animation_timer --duration 1000 --loop
    ;;
  reversed)
    stdlib_animation_timer --duration 1000 --reversed
    ;;
  alternate)
    stdlib_animation_timer --duration 1000 --loop --alternate
    ;;
  speed)
    stdlib_animation_timer --duration 1000 --loop --alternate --fps 60
    ;;
  esac
  break
done
