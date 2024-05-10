#!/bin/zsh

export YSU_VERSION='1.7.3'

zstyle ':you-should-use:*' you_should_use_alias_enabled true
zstyle ':you-should-use:*' you_used_alias_enabled true
zstyle ':you-should-use:*' you_should_use_abbreviation_enabled true

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

function load_abbrs() {
    typeset -gA abbrs
    local line abbr_cmd abbr_expansion

    # Fetch abbreviation list directly using abbr list command
    abbr list | while IFS="=" read -r abbr_cmd abbr_expansion; do
        # Remove quotes around the command and expansion
        abbr_cmd=${abbr_cmd//\"/}
        abbr_expansion=${abbr_expansion//\"/}

        # Store in associative array
        abbrs[$abbr_cmd]=$abbr_expansion
    done
}


function load_abbrs_from_file() {
    # Fetch abbreviation list from file
    local abbr_file="$ABBR_USER_ABBREVIATIONS_FILE"
    declare -gA abbrs   # Ensure 'abbrs' is declared as a global associative array
    local line abbr_cmd abbr_expansion

    while IFS="" read -r line || [[ -n $line ]]; do
        if [[ "$line" =~ ^abbr\ \"([^\"]+)\"\=\"([^\"]+)\" ]]; then
            abbr_cmd=${match[1]}
            abbr_expansion=${match[2]}
            abbrs[$abbr_expansion]=$abbr_cmd
        fi
    done < "$abbr_file"
}

function _check_abbrs() {
    local typed="$1"
    # Directly using the typed command to look up its abbreviation
    local abbr_match="${abbrs[$typed]}"

    if [[ -n "$abbr_match" ]]; then
        ysu_message "abbreviation" "$typed" "$abbr_match"
        if [[ "$YSU_HARDCORE" = 1 ]]; then
            _write_ysu_buffer "${BOLD}${RED}You Should Use abbreviation mode enabled. Use your abbreviation!${NONE}\n"
            kill -s INT $$
        fi
    fi
}

function _check_aliases() {
    local typed="$1"
    local expanded="$2"
    local first_word="${typed%% *}"
    local found=false

    for key in "${(@k)aliases}"; do
        value="${aliases[$key]}"
        if [[ "$first_word" == "$key" ]]; then
            found=true
            ysu_message "used alias" "$key" "$value"
            break
        fi
    done

    if $found; then
        _check_ysu_hardcore
    else
        # Continue with other checks if not found
        _find_and_recommend_aliases "$typed"
    fi
}

function check_alias_usage() {
    # Optional parameter that limits how far back history is checked
    # I've chosen a large default value instead of bypassing tail because it's simpler
    # TODO: this should probably be cleaned up
    local limit="${1:-$HISTSIZE}"
    local key

    declare -A usage
    for key in "${(@k)aliases}"; do
        usage[$key]=0
    done

    # TODO:
    # Handle and (&&) + (&)
    # others? watch, time etc...

    local current=0
    local total=$(wc -l < "$HISTFILE")
    if [[ $total -gt $limit ]]; then
        total=$limit
    fi

    <"$HISTFILE" | tail "-$limit" | cut -d";" -f2 | while read line; do
        local entry
        for entry in ${(@s/|/)line}; do
            # Remove leading whitespace
            # TODO: This is extremely slow
            entry="$(echo "$entry" | sed -e 's/^ *//')"

            # We only care about the first word because that's all aliases work with
            # (this does not count global and git aliases)
            local word=${entry[(w)1]}
            if [[ -n ${usage[$word]} ]]; then
                local prev=$usage[$word]
                let "prev = prev + 1 "
                usage[$word]=$prev
            fi
        done

        # print current progress
        let "current = current + 1"
        printf "[$current/$total]\r"
    done
    # Clear all previous line output
    printf "\r\033[K"

    # Print ordered usage
    for key in ${(k)usage}; do
        echo "${usage[$key]}: $key='${aliases[$key]}'"
    done | sort -rn -k1
}

# Writing to a buffer rather than directly to stdout/stderr allows us to decide
# if we want to write the reminder message before or after a command has been executed
function _write_ysu_buffer() {
    _YSU_BUFFER+="$@"

    # Maintain historical behaviour by default
    local position="${YSU_MESSAGE_POSITION:-before}"
    if [[ "$position" = "before" ]]; then
        _flush_ysu_buffer
    elif [[ "$position" != "after" ]]; then
        (>&2 printf "${RED}${BOLD}Unknown value for YSU_MESSAGE_POSITION '$position'. ")
        (>&2 printf "Expected value 'before' or 'after'${NONE}\n")
        _flush_ysu_buffer
    fi
}

function _flush_ysu_buffer() {
    # It's important to pass $_YSU_BUFFER to printfs first argument
    # because otherwise all escape codes will not printed correctly
    (>&2 printf "$_YSU_BUFFER")
    _YSU_BUFFER=""
}

function ysu_message() {
    local message_type="$1"
    local command_arg="$2"
    local abbreviation_arg="$3"
    local DEFAULT_MESSAGE_FORMAT=""

    # Escape arguments for safe output
    command_arg="${command_arg//\%/%%}"
    command_arg="${command_arg//\\/\\\\}"
    abbreviation_arg="${abbreviation_arg//\%/%%}"
    abbreviation_arg="${abbreviation_arg//\\/\\\\}"

    # Determine message format based on message type and whether it's enabled
    case "$message_type" in
        "abbreviation")
            if zstyle -t ':you-should-use:*' you_should_use_abbreviation_enabled; then
                DEFAULT_MESSAGE_FORMAT="${BOLD}${YELLOW}Found existing abbreviation for ${PURPLE}\"$command_arg\"${YELLOW}. \
You should use: ${PURPLE}\"$abbreviation_arg\"${NONE}"
            fi
            ;;
        "alias")
            if zstyle -t ':you-should-use:*' you_should_use_alias_enabled; then
                DEFAULT_MESSAGE_FORMAT="${BOLD}${YELLOW}Found existing alias for ${PURPLE}\"$command_arg\"${YELLOW}. \
You should use: ${PURPLE}\"$abbreviation_arg\"${NONE}"
            fi
            ;;
        "used alias")
            if zstyle -t ':you-should-use:*' you_used_alias_enabled; then
                DEFAULT_MESSAGE_FORMAT="${BOLD} ${PURPLE}\"$command_arg\"${YELLOW} -> ${PURPLE}\"$abbreviation_arg\"${NONE}"
            fi
            ;;
    esac
    _write_ysu_buffer "$DEFAULT_MESSAGE_FORMAT\n"
}

# Prevent command from running if hardcore mode enabled
function _check_ysu_hardcore() {
    if [[ "$YSU_HARDCORE" = 1 ]]; then
        _write_ysu_buffer "${BOLD}${RED}You Should Use hardcore mode enabled. Use your aliases!${NONE}\n"
        kill -s INT $$
    fi
}

function _check_git_aliases() {
    local typed="$1"
    local expanded="$2"

    # sudo will use another user's profile and so aliases would not apply
    if [[ "$typed" = "sudo "* ]]; then
        return
    fi

    if [[ "$typed" = "git "* ]]; then
        local found=false
        git config --get-regexp "^alias\..+$" | sort | while read key value; do
            key="${key#alias.}"

            if [[ "$expanded" = "git $value" || "$expanded" = "git $value "* ]]; then
                ysu_message "git alias" "$value" "git $key"
                found=true
            fi
        done

        if $found; then
            _check_ysu_hardcore
        fi
    fi
}

function _check_global_aliases() {
    local typed="$1"
    local expanded="$2"

    local found=false
    local tokens
    local key
    local value
    local entry

    # sudo will use another user's profile and so aliases would not apply
    if [[ "$typed" = "sudo "* ]]; then
        return
    fi

    alias -g | sort | while read entry; do
        tokens=("${(@s/=/)entry}")
        key="${tokens[1]}"
        # Need to remove leading and trailing ' if they exist
        value="${(Q)tokens[2]}"

        # Skip ignored global aliases
        if [[ ${YSU_IGNORED_GLOBAL_ALIASES[(r)$key]} == "$key" ]]; then
            continue
        fi

        if [[ "$typed" = *" $value "* || \
              "$typed" = *" $value" || \
              "$typed" = "$value "* || \
              "$typed" = "$value" ]]; then
            ysu_message "global alias" "$value" "$key"
            found=true
        fi
    done

    if $found; then
        _check_ysu_hardcore
    fi
}

function _check_aliases() {
    local typed="$1"
    local expanded="$2"

    local first_word="${typed%% *}"  # Extracts the first word from the typed command
    local found_aliases=()
    local best_match=""
    local best_match_value=""
    local key
    local value
    local found=false

    # sudo will use another user's profile and so aliases would not apply
    if [[ "$typed" = "sudo "* ]]; then
        return
    fi

    # Check if the first word of the typed command is an alias directly
    for key in "${(@k)aliases}"; do
        value="${aliases[$key]}"
        if [[ "$first_word" = "$key" ]]; then  # Check if first word is exactly an alias
            ysu_message "used alias" "$key" "$value"  # Inform that the alias expands to the full command
            found=true
            break
        fi
    done

    if $found; then
        _check_ysu_hardcore
        return
    fi

    # Find alias matches based on the full command
    for key in "${(@k)aliases}"; do
        value="${aliases[$key]}"

        # Skip ignored aliases
        if [[ ${YSU_IGNORED_ALIASES[(r)$key]} == "$key" ]]; then
            continue
        fi

        if [[ "$first_word" = "$value" || "$first_word" = "$value "* ]]; then
            # if the alias is longer or the same length as its command
            # we assume that it is there to cater for typos.
            # If not, then the alias would not save any time
            # for the user and so doesn't hold much value anyway
            if [[ "${#value}" -gt "${#key}" ]]; then
                found_aliases+="$key"
                # Match aliases to the longest portion of command
                if [[ "${#value}" -gt "${#best_match_value}" ]]; then
                    best_match="$key"
                    best_match_value="$value"
                # On equal length, choose the shortest alias
                elif [[ "${#value}" -eq "${#best_match_value}" && ${#key} -lt "${#best_match}" ]]; then
                    best_match="$key"
                    best_match_value="$value"
                fi
            fi
        fi
    done

    # Print result matches based on current mode
    if [[ "$YSU_MODE" = "ALL" ]]; then
        for key in ${(@ok)found_aliases}; do
            value="${aliases[$key]}"
            ysu_message "alias" "$value" "$key"
        done
    elif [[ (-z "$YSU_MODE" || "$YSU_MODE" = "BESTMATCH") && -n "$best_match" ]]; then
        # Make sure that the best matched alias has not already
        # been typed by the user
        value="${aliases[$best_match]}"
        if [[ "$typed" = "$best_match" || "$typed" = "$best_match "* ]]; then
            return
        fi
        ysu_message "alias" "$value" "$best_match"
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
    add-zsh-hook -D preexec _check_abbrs
}

function enable_you_should_use() {
    disable_you_should_use   # Delete any possible pre-existing hooks
    add-zsh-hook preexec _check_aliases
    add-zsh-hook preexec _check_global_aliases
    add-zsh-hook preexec _check_git_aliases
    add-zsh-hook precmd _flush_ysu_buffer
    add-zsh-hook preexec _check_abbrs
}

autoload -Uz add-zsh-hook
enable_you_should_use
load_abbrs
