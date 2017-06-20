#!/bin/zsh

function _check_aliases() {
  local BOLD='\033[1m'
  local RED='\e[31m'
  local NONE='\033[00m'
  local FOUND_ALIAS=()
  for k in "${(@k)aliases}"; do
    local v="${aliases[$k]}"
    if [[ "$1" = "$v" || "$1" = "$v "* ]]; then
      FOUND_ALIAS+="$k"
    fi
  done

  local best_match=""
  local best_match_key=""
  for k in $FOUND_ALIAS; do
    local v="${aliases[$k]}"
    if [[ "${#v}" > "${#best_match}" ]]; then
      best_match="$v"
      best_match_key="$k"
    fi

    if [[ -z "$YSU_MODE" || "$YSU_MODE" = "ALL" ]]; then
      echo "${BOLD}Found existing alias for \"$v\". You should use: \"$k\"${NONE}"
    fi
  done

  if [[ "$YSU_MODE" = "BESTMATCH" && -n "$best_match" ]]; then
      echo "${BOLD}Found existing alias for \"$best_match\". You should use: \"$best_match_key\"${NONE}"
  fi

  if [[ "$YSU_HARDCORE" = 1 && -n "$FOUND_ALIAS" ]]; then
      echo "${BOLD}${RED}You Should Use hardcore mode enabled. Use your aliases!${NONE}"
      kill -s INT $$
  fi
}

add-zsh-hook preexec _check_aliases
