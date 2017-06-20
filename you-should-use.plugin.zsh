#!/bin/zsh

function ysu_message() {
  echo "${BOLD}Found existing alias for \"$1\". You should use: \"$2\"${NONE}"
}


function _check_aliases() {
  local BOLD='\033[1m'
  local RED='\e[31m'
  local NONE='\033[00m'
  local found_aliases=()
  local best_match=""
  local best_match_key=""

  # Find alias matches
  for k in "${(@k)aliases}"; do
    local v="${aliases[$k]}"
    if [[ "$1" = "$v" || "$1" = "$v "* ]]; then
      found_aliases+="$k"

      if [[ "${#v}" -gt "${#best_match}" ]]; then
        best_match="$v"
        best_match_key="$k"
      fi
    fi
  done

  # Print result matches based on current mode
  if [[ -z "$YSU_MODE" || "$YSU_MODE" = "ALL" ]]; then
    for k in $found_aliases; do
      local v="${aliases[$k]}"
      ysu_message "$v" "$k"
    done

  elif [[ "$YSU_MODE" = "BESTMATCH" && -n "$best_match" ]]; then
    ysu_message "$best_match" "$best_match_key"
  fi

  # Prevent command from running if hardcore mode enabled
  if [[ "$YSU_HARDCORE" = 1 && -n "$found_aliases" ]]; then
      echo "${BOLD}${RED}You Should Use hardcore mode enabled. Use your aliases!${NONE}"
      kill -s INT $$
  fi
}

add-zsh-hook preexec _check_aliases
