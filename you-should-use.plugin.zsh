#!/bin/zsh

function _check_aliases() {
  local BOLD='\033[1m'
  local RED='\e[31m'
  local NONE='\033[00m'
  local FOUND_ALIAS=0
  for k in "${(@k)aliases}"; do
    local v="${aliases[$k]}"
    if [[ "$1" = "$v"* ]]; then
      echo "${BOLD}Found existing alias for \"$v\". You should use: \"$k\"${NONE}"
      FOUND_ALIAS=1
    fi
  done

  if [[ "$YSU_HARDCORE" = 1 && "$FOUND_ALIAS" = 1 ]]; then
      echo "${BOLD}${RED}You Should Use hardcore mode enabled. Use your aliases!${NONE}"
      kill -s INT $$
  fi
}

add-zsh-hook preexec _check_aliases
