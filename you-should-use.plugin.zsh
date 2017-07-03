#!/bin/zsh

function ysu_message() {
  local BOLD='\033[1m'
  local NONE='\033[00m'
  echo "${BOLD}Found existing alias for \"$1\". You should use: \"$2\"${NONE}"
}


function ysu_global_message() {
  local BOLD='\033[1m'
  local NONE='\033[00m'
  echo "${BOLD}Found existing global alias for \"$1\". You should use: \"$2\"${NONE}"
}


function ysu_git_message() {
  local BOLD='\033[1m'
  local NONE='\033[00m'
  echo "${BOLD}Found existing git alias for \"$1\". You should use: \"git $2\"${NONE}"
}


# Prevent command from running if hardcore mode enabled
function _check_ysu_hardcore() {
  if [[ "$YSU_HARDCORE" = 1 ]]; then
      local RED='\e[31m'
      local BOLD='\033[1m'
      local NONE='\033[00m'
      echo "${BOLD}${RED}You Should Use hardcore mode enabled. Use your aliases!${NONE}"
      kill -s INT $$
  fi
}


function _check_git_aliases() {
  if [[ "$2" = "git "* ]]; then
      local found=false
      local tokens
      local k
      local v
      git config --get-regexp "^alias\..+$" | sort | while read entry; do
        tokens=("${(@s/ /)entry}")
        k="${tokens[1]#alias.}"
        v="${tokens[2]}"

        if [[ "$2" = "git $v" || "$2" = "git $v "* ]]; then
          ysu_git_message "$v" "$k"
          found=true
        fi
      done

      if $found; then
       _check_ysu_hardcore
      fi
  fi
}


function _check_global_aliases() {
  local found=false
  local tokens
  local k
  local v
  alias -g | sort | while read entry; do
    tokens=("${(@s/=/)entry}")
    k="${tokens[1]}"
    # Need to remove leading and trailing ' if they exist
    v="${(Q)tokens[2]}"

    if [[ "$1" = *"$v"* ]]; then
      ysu_global_message "$v" "$k"
      found=true
    fi
  done

  if $found; then
   _check_ysu_hardcore
  fi
}


function _check_aliases() {
  local found_aliases
  found_aliases=()
  local best_match=""
  local v

  # Find alias matches
  for k in "${(@ok)aliases}"; do
    v="${aliases[$k]}"

    if [[ "$1" = "$v" || "$1" = "$v "* ]]; then

      # if the alias longer or the same length as its command
      # we assume that it is there to cater for typos.
      # If not, then the alias would not save any time
      # for the user and so doesnt hold much value anyway
      if [[ "${#v}" -gt "${#k}" ]]; then

        found_aliases+="$k"

        # Match aliases to longest portion of command
        if [[ "${#v}" -gt "${#best_match}" ]]; then
            best_match="$k"
          # on equal length, choose the shortest alias
          elif [[ "${#v}" -eq "${#best_match}" && ${#k} -lt "${#best_match}" ]]; then
            best_match="$k"
          fi
        fi
      fi
  done

  # Print result matches based on current mode
  if [[ -z "$YSU_MODE" || "$YSU_MODE" = "ALL" ]]; then
    for k in $found_aliases; do
      v="${aliases[$k]}"
      ysu_message "$v" "$k"
    done

  elif [[ "$YSU_MODE" = "BESTMATCH" && -n "$best_match" ]]; then
    v="${aliases[$best_match]}"
    ysu_message "$v" "$best_match"
  fi

  if [[ -n "$found_aliases" ]]; then
    _check_ysu_hardcore
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook -D preexec _check_aliases
add-zsh-hook -D preexec _check_global_aliases
add-zsh-hook -D preexec _check_git_aliases

add-zsh-hook preexec _check_aliases
add-zsh-hook preexec _check_global_aliases
add-zsh-hook preexec _check_git_aliases
