#!/bin/zsh

function lsalias() {
  for k in "${(@k)aliases}"; do
    echo "$k = \"$aliases[$k]\""
  done
}

function _check_aliases() {
  for k in "${(@k)aliases}"; do
    v="${aliases[$k]}"
    if [[ "$1" = "$v"* ]]; then
      echo "Found existing alias for \"$v\". You should use: \"$k\""
    fi
  done
}

add-zsh-hook preexec _check_aliases
