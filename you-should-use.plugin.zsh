#!/bin/zsh

function lsalias() {
  for k in "${(@k)aliases}"; do
    echo "$k = \"$aliases[$k]\""
  done
}

function _check_aliases() {
  BOLD='\033[1m'
  NONE='\033[00m'
  for k in "${(@k)aliases}"; do
    v="${aliases[$k]}"
    if [[ "$1" = "$v"* ]]; then
      echo "${BOLD}Found existing alias for \"$v\". You should use: \"$k\"${NONE}"
    fi
  done
}

add-zsh-hook preexec _check_aliases
