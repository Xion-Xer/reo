#!/usr/bin/env bash

RESET="\033[0m"

BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"

BRIGHT_BLACK="\033[90m"
BRIGHT_RED="\033[91m"
BRIGHT_GREEN="\033[92m"
BRIGHT_YELLOW="\033[93m"
BRIGHT_BLUE="\033[94m"
BRIGHT_MAGENTA="\033[95m"
BRIGHT_CYAN="\033[96m"
BRIGHT_WHITE="\033[97m"

consolog() {
    TYPE="$1"
    TEXT="$2"

    case "$TYPE" in
        black) COLOR="$BLACK" ;;
        red) COLOR="$RED" ;;
        green) COLOR="$GREEN" ;;
        yellow) COLOR="$YELLOW" ;;
        blue) COLOR="$BLUE" ;;
        magenta) COLOR="$MAGENTA" ;;
        cyan) COLOR="$CYAN" ;;
        white) COLOR="$WHITE" ;;

        bright_black) COLOR="$BRIGHT_BLACK" ;;
        bright_red) COLOR="$BRIGHT_RED" ;;
        bright_green) COLOR="$BRIGHT_GREEN" ;;
        bright_yellow) COLOR="$BRIGHT_YELLOW" ;;
        bright_blue) COLOR="$BRIGHT_BLUE" ;;
        bright_magenta) COLOR="$BRIGHT_MAGENTA" ;;
        bright_cyan) COLOR="$BRIGHT_CYAN" ;;
        bright_white) COLOR="$BRIGHT_WHITE" ;;

        success) COLOR="$GREEN" ;;
        error) COLOR="$RED" ;;
        warn) COLOR="$YELLOW" ;;
        info) COLOR="$BLUE" ;;

        *) COLOR="$RESET" ;;
    esac

    echo -e "${COLOR}${TEXT}${RESET}"
}
