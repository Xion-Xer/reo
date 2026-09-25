#!/usr/bin/env bash

RESET="\033[0m"

BRIGHT_CYAN="\033[96m"
BRIGHT_RED="\033[91m"

ask() {
    TEXT="$1"

    while true; do
        echo -ne "${BRIGHT_CYAN}${TEXT}: ${RESET}" > /dev/tty
        read VALUE < /dev/tty

        # remove spaces start/end
        VALUE=$(echo "$VALUE" | sed 's/^ *//;s/ *$//')

        # empty check
        if [ -z "$VALUE" ]; then
            echo -e "${BRIGHT_RED}Input required${RESET}" > /dev/tty
            continue
        fi

        # url encode spaces
        printf '%s' "$VALUE" | sed 's/ /%20/g'
        return
    done
}
