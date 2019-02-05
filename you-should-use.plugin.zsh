#!/bin/zsh

export YSU_VERSION='1.1.0'

if ! type "tput" > /dev/null; then
    printf "WARNING: tput command not found on your PATH.\n"
    printf "zsh-you-should-use will fallback to uncoloured messages\n"
else
    NONE="$(tput sgr0)"
    BOLD="$(tput bold)"
    RED="$(tput setaf 1)"
    YELLOW="$(tput setaf 3)"
    PURPLE="$(tput setaf 5)"
fi

# Writing to a buffer rather than directly to stdout/stderr allows us to decide
# if we want to write the reminder message before or after a command has been executed
function _write_ysu_buffer() {
    YSU_BUFFER+="$@"

    # Maintain historical behaviour by default
    position="${YSU_MESSAGE_POSITION:-before}"
    if [[ "$position" = "before" ]]; then
        _flush_ysu_buffer
    elif [[ "$position" != "after" ]]; then
        (>&2 printf "${RED}${BOLD}Unknown value for YSU_MESSAGE_POSITION '$position'. ")
        (>&2 printf "Expected value 'before' or 'after'${NONE}\n")
        _flush_ysu_buffer
    fi
}

function _flush_ysu_buffer() {
    (>&2 printf "$YSU_BUFFER")
    YSU_BUFFER=""
}

function ysu_message() {
  DEFAULT_MESSAGE_FORMAT="${BOLD}${YELLOW}\
Found existing %alias_type for ${PURPLE}\"%command\"${YELLOW}. \
You should use: ${PURPLE}\"%alias\"${NONE}"

  local MESSAGE="${YSU_MESSAGE_FORMAT:-"$DEFAULT_MESSAGE_FORMAT"}"
  MESSAGE="${MESSAGE//\%alias_type/$1}"
  MESSAGE="${MESSAGE//\%command/$2}"
  MESSAGE="${MESSAGE//\%alias/$3}"

  _write_ysu_buffer "$MESSAGE\n"
}


# Prevent command from running if hardcore mode enabled
function _check_ysu_hardcore() {
  if [[ "$YSU_HARDCORE" = 1 ]]; then
      _write_ysu_buffer "${BOLD}${RED}You Should Use hardcore mode enabled. Use your aliases!${NONE}\n"
      kill -s INT $$
  fi
}


function _check_git_aliases() {
  if [[ "$1" = "git "* ]]; then
      local found=false
      local k
      local v
      git config --get-regexp "^alias\..+$" | sort | while read k v; do
        k="${k#alias.}"

        if [[ "$2" = "git $v" || "$2" = "git $v "* ]]; then
          ysu_message "git alias" "$v" "git $k"
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
      ysu_message "global alias" "$v" "$k"
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
  local best_match_value=""
  local v

  # Find alias matches
  for k in "${(@k)aliases}"; do
    v="${aliases[$k]}"

    if [[ "$1" = "$v" || "$1" = "$v "* ]]; then

      # if the alias longer or the same length as its command
      # we assume that it is there to cater for typos.
      # If not, then the alias would not save any time
      # for the user and so doesn't hold much value anyway
      if [[ "${#v}" -gt "${#k}" ]]; then

        found_aliases+="$k"

        # Match aliases to longest portion of command
        if [[ "${#v}" -gt "${#best_match_value}" ]]; then
          best_match="$k"
          best_match_value="$v"
        # on equal length, choose the shortest alias
        elif [[ "${#v}" -eq "${#best_match}" && ${#k} -lt "${#best_match}" ]]; then
          best_match="$k"
          best_match_value="$v"
        fi
      fi
    fi
  done

  # Print result matches based on current mode
  if [[ "$YSU_MODE" = "ALL" ]]; then
    for k in ${(@ok)found_aliases}; do
      v="${aliases[$k]}"
      ysu_message "alias" "$v" "$k"
    done

  elif [[ (-z "$YSU_MODE" || "$YSU_MODE" = "BESTMATCH") && -n "$best_match" ]]; then
    v="${aliases[$best_match]}"
    ysu_message "alias" "$v" "$best_match"
  fi

  if [[ -n "$found_aliases" ]]; then
    _check_ysu_hardcore
  fi
}

function disable_you_should_use() {
    add-zsh-hook -D preexec _check_aliases
    add-zsh-hook -D preexec _check_global_aliases
    add-zsh-hook -D preexec _check_git_aliases
    add-zsh-hook -D precmd _flush_ysu_buffer
}

function enable_you_should_use() {
    disable_you_should_use   # Delete any possible pre-existing hooks
    add-zsh-hook preexec _check_aliases
    add-zsh-hook preexec _check_global_aliases
    add-zsh-hook preexec _check_git_aliases
    add-zsh-hook precmd _flush_ysu_buffer
}

autoload -Uz add-zsh-hook
enable_you_should_use
