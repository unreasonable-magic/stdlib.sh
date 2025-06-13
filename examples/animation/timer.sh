#!/usr/bin/env bash

eval "$(stdlib shellenv)"

stdlib::import "animation/timer"

select example in simple loop reversed alternate speed
do
  case "$example" in
    simple)
      timer --duration 1000
      ;;
    loop)
      timer --duration 1000 --loop
      ;;
    reversed)
      timer --duration 1000 --reversed
      ;;
    alternate)
      timer --duration 1000 --loop --alternate
      ;;
    speed)
      timer --duration 1000 --loop --alternate --fps 60
      ;;
  esac
  break
done
