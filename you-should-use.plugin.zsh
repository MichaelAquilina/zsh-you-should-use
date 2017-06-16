#!/bin/zsh

function _check_aliases() {
  typeset -g -A ialiases
  for k in "${(@k)aliases}"; do
    v="${aliases[$k]}"
    ialiases["$v"]="$k"
  done

  v="${ialiases["$1"]}"
  if [[ -n "$v" ]]; then
    echo "Alias exists for '$1'. You should use '$v'"
  fi
}

add-zsh-hook preexec _check_aliases
