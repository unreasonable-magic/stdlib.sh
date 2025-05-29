#!/usr/bin/env bash

if [[ "${BASH_VERSION:0:1}" == "3" ]]; then
  stdlib::string::downcase() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
  }
else
  stdlib::string::downcase() {
    echo "${1,,}"
  }
fi

stdlib::string::underscore() {
  echo "${1// /_}"
}
