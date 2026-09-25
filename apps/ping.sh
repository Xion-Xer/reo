#!/usr/bin/env bash

# name: ping
# description: Ping a host or URL and show response times

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT_DIR/core/index.sh"

BOLD="\033[1m"

DEFAULT_TARGET="duckduckgo.com"

TARGET="${1:-$DEFAULT_TARGET}"
COUNT="${2:-4}"

if [[ "$TARGET" == "$DEFAULT_TARGET" && -z "$1" ]]; then
    consolog bright_black "No host given, defaulting to $DEFAULT_TARGET"
fi

if ! [[ "$COUNT" =~ ^[0-9]+$ ]] || [[ "$COUNT" -lt 1 ]]; then
    COUNT=4
fi

# normalize target into a full URL
if [[ "$TARGET" != *"://"* ]]; then
    URL="https://$TARGET"
else
    URL="$TARGET"
fi

echo
consolog bright_cyan "Pinging ${TARGET} ..."
echo

TIMES=()
SUCCESS=0
FAIL=0

for ((i = 1; i <= COUNT; i++)); do
    RESULT=$(curl -o /dev/null -s \
        --connect-timeout 5 \
        --max-time 10 \
        -w "%{http_code} %{time_total}" \
        "$URL" 2>/dev/null)

    CURL_EXIT=$?

    if [[ $CURL_EXIT -ne 0 || -z "$RESULT" ]]; then
        echo -e "  ${BRIGHT_RED}✗ request $i failed (timeout/unreachable)${RESET}"
        ((FAIL++))
        continue
    fi

    HTTP_CODE=$(echo "$RESULT" | awk '{print $1}')
    TIME_TOTAL=$(echo "$RESULT" | awk '{print $2}')
    MS=$(awk -v t="$TIME_TOTAL" 'BEGIN { printf "%.0f", t * 1000 }')

    if [[ "$HTTP_CODE" == "000" ]]; then
        echo -e "  ${BRIGHT_RED}✗ request $i failed (no response)${RESET}"
        ((FAIL++))
        continue
    fi

    TIMES+=("$MS")
    ((SUCCESS++))
    echo -e "  ${BRIGHT_GREEN}✓${RESET} reply from ${WHITE}${TARGET}${RESET}: status=${CYAN}${HTTP_CODE}${RESET} time=${YELLOW}${MS}ms${RESET}"

    [[ $i -lt $COUNT ]] && sleep 0.3
done

echo
consolog bright_cyan "╔══════════════════════════════╗"
consolog bright_cyan "║          PING SUMMARY        ║"
consolog bright_cyan "╚══════════════════════════════╝"

LOSS=$(awk -v f="$FAIL" -v c="$COUNT" 'BEGIN { printf "%.0f", (f/c)*100 }')

echo -e "  ${BRIGHT_WHITE}${BOLD}Sent${RESET}       ${WHITE}${COUNT}${RESET}"
echo -e "  ${BRIGHT_WHITE}${BOLD}Received${RESET}   ${WHITE}${SUCCESS}${RESET}"
echo -e "  ${BRIGHT_WHITE}${BOLD}Loss${RESET}       ${WHITE}${LOSS}%${RESET}"

if [[ ${#TIMES[@]} -gt 0 ]]; then
    MIN=${TIMES[0]}
    MAX=${TIMES[0]}
    SUM=0
    for t in "${TIMES[@]}"; do
        (( t < MIN )) && MIN=$t
        (( t > MAX )) && MAX=$t
        SUM=$((SUM + t))
    done
    AVG=$((SUM / ${#TIMES[@]}))

    echo -e "  ${BRIGHT_WHITE}${BOLD}Min/Avg/Max${RESET} ${WHITE}${MIN}ms / ${AVG}ms / ${MAX}ms${RESET}"
fi

echo
