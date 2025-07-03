#!/usr/bin/env bash

test_data="The quick brown fox jumps over the lazy dog"

benchmark() {
  local func="$1"
  local data="$2"
  local iterations=1000

  start=$(date +%s.%N)
  for ((i=0; i<iterations; i++)); do
    $func "$data" >/dev/null
  done
  end=$(date +%s.%N)

  runtime=$(echo "$end - $start" | bc -l)
  echo "$func: ${runtime}s for $iterations iterations"
}

test_base64() { printf "%s" "$1" | base64; }
test_xxd() { printf "%s" "$1" | xxd -p | tr -d '\n'; }
test_od() { printf "%s" "$1" | od -A n -t x1 | tr -d ' \n'; }
test_custom() {
  local str="$1"
  local hex=""
  local i

  for ((i=0; i<${#str}; i++)); do
    printf -v hex "%s%02x" "$hex" "'${str:i:1}"
  done

  printf "%s" "$hex"
}

benchmark test_base64 "$test_data"
benchmark test_xxd "$test_data"
benchmark test_od "$test_data"
benchmark test_custom "$test_data"
