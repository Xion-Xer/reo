#!/usr/bin/env bash

# name: duckduckgo
# description: Search the web via DuckDuckGo

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT_DIR/core/index.sh"

QUERY=$(ask "Search")

clear
echo
echo

consolog bright_yellow "╔══════════════════════════════╗"
consolog bright_yellow "║      DUCKDUCKGO SEARCH       ║"
consolog bright_yellow "╚══════════════════════════════╝"

echo
echo

RESPONSE=$(fetch "https://lokixer.koyeb.app/search/duckgo?q=$QUERY")

STATUS=$(echo "$RESPONSE" | grep -o '"status":[^,]*' | cut -d':' -f2)
MESSAGE=$(echo "$RESPONSE" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)

if [[ "$STATUS" != "true" ]]; then

    if [[ -n "$MESSAGE" ]]; then
        consolog bright_red "Error: $MESSAGE"
    else
        consolog bright_red "Failed to fetch search results"
    fi

    echo
    exit 1
fi

# No result check
RESULTS=$(echo "$RESPONSE" | grep -o '{"title":"[^"]*","link":"[^"]*","description":"[^"]*"}')

if [[ -z "$RESULTS" ]]; then
    consolog bright_red "No results found"
    echo
    exit 1
fi

COUNT=1

echo "$RESULTS" | while read ITEM; do

    TITLE=$(echo "$ITEM" | cut -d'"' -f4)
    LINK=$(echo "$ITEM" | cut -d'"' -f8)
    DESC=$(echo "$ITEM" | cut -d'"' -f12)

    # fallback values
    [ -z "$TITLE" ] && TITLE="Unknown Title"
    [ -z "$LINK" ] && LINK="#"
    [ -z "$DESC" ] && DESC="No description"

    consolog bright_cyan "$COUNT $TITLE"

    echo

    consolog white "$DESC"

    echo

    consolog bright_blue "$LINK"

    echo

    consolog bright_black "────────────────────────────────────────────"

    echo

    COUNT=$((COUNT + 1))

done
