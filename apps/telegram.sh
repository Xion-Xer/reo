#!/usr/bin/env bash

# name: telegram
# description: Lookup Telegram users

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT_DIR/core/index.sh"

QUERY=$(ask "Username")

clear

RESPONSE=$(fetch "https://lokixer.koyeb.app/stalk/telegram?query=$QUERY")

STATUS=$(echo "$RESPONSE" | grep -o '"status":[^,]*' | cut -d':' -f2)
MESSAGE=$(echo "$RESPONSE" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)

if [[ "$STATUS" != "true" ]]; then
    consolog bright_red "╔══════════════════════════╗"
    consolog bright_red "║          ERROR           ║"
    consolog bright_red "╚══════════════════════════╝"

    echo

    if [[ -n "$MESSAGE" ]]; then
        consolog bright_red "$MESSAGE"
    else
        consolog bright_red "Failed to fetch Telegram user"
    fi

    exit 1
fi

USERNAME=$(echo "$RESPONSE" | grep -o '"userName":"[^"]*"' | cut -d'"' -f4)
NICKNAME=$(echo "$RESPONSE" | grep -o '"nickName":"[^"]*"' | cut -d'"' -f4)
ABOUT=$(echo "$RESPONSE" | grep -o '"about":"[^"]*"' | cut -d'"' -f4)
TELEGRAM=$(echo "$RESPONSE" | grep -o '"telegram":"[^"]*"' | cut -d'"' -f4)
PROFILE=$(echo "$RESPONSE" | grep -o '"profile":"[^"]*"' | cut -d'"' -f4)

[ -z "$USERNAME" ] && USERNAME="Not Found"
[ -z "$NICKNAME" ] && NICKNAME="Not Found"
[ -z "$ABOUT" ] && ABOUT="No Bio"
[ -z "$TELEGRAM" ] && TELEGRAM="Not Available"
[ -z "$PROFILE" ] && PROFILE="No Profile"

consolog bright_cyan "╔══════════════════════════╗"
consolog bright_cyan "║     TELEGRAM LOOKUP      ║"
consolog bright_cyan "╚══════════════════════════╝"

echo

consolog bright_white   "Name     : $NICKNAME"
consolog bright_green   "Username : $USERNAME"
consolog bright_blue    "Telegram : $TELEGRAM"
consolog bright_magenta "Profile  : $PROFILE"

echo

consolog bright_yellow "$ABOUT"
