#!/usr/bin/env bash

# name: ip
# description: Look up your public IP, or info about any IP/domain

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT_DIR/core/index.sh"

BOLD="\033[1m"

QUERY="$1"

if [[ -n "$QUERY" ]]; then
    API_URL="https://ipapi.co/${QUERY}/json/"
else
    API_URL="https://ipapi.co/json/"
fi

RESPONSE=$(fetch "$API_URL")

# ipapi.co style errors, e.g. {"error":true,"reason":"Invalid IP Address"}
if echo "$RESPONSE" | grep -q '"error":true'; then
    REASON=$(echo "$RESPONSE" | grep -oP '"reason":"\K[^"]*')
    consolog bright_red "Lookup failed: ${REASON:-Invalid IP or domain}"
    exit 1
fi

# our own fetch() wrapper's failure shape
if echo "$RESPONSE" | grep -q '"status":false'; then
    MESSAGE=$(echo "$RESPONSE" | grep -oP '"message":"\K[^"]*')
    consolog bright_red "Lookup failed: ${MESSAGE:-Network error}"
    exit 1
fi

IP=$(echo "$RESPONSE"        | grep -oP '"ip":"\K[^"]*')
CITY=$(echo "$RESPONSE"      | grep -oP '"city":"\K[^"]*')
REGION=$(echo "$RESPONSE"    | grep -oP '"region":"\K[^"]*')
COUNTRY=$(echo "$RESPONSE"   | grep -oP '"country_name":"\K[^"]*')
CC=$(echo "$RESPONSE"        | grep -oP '"country_code":"\K[^"]*')
POSTAL=$(echo "$RESPONSE"    | grep -oP '"postal":"?\K[^",}]*')
LAT=$(echo "$RESPONSE"       | grep -oP '"latitude":\K[^,}]*')
LON=$(echo "$RESPONSE"       | grep -oP '"longitude":\K[^,}]*')
TZ=$(echo "$RESPONSE"        | grep -oP '"timezone":"\K[^"]*')
ORG=$(echo "$RESPONSE"       | grep -oP '"org":"\K[^"]*')
ASN=$(echo "$RESPONSE"       | grep -oP '"asn":"\K[^"]*')

if [[ -z "$IP" ]]; then
    consolog bright_red "Could not parse a response. Try again in a moment."
    exit 1
fi

clear
echo
consolog bright_cyan "╔══════════════════════════════╗"
consolog bright_cyan "║           IP LOOKUP          ║"
consolog bright_cyan "╚══════════════════════════════╝"
echo

echo -e "  ${BRIGHT_WHITE}${BOLD}IP${RESET}         ${WHITE}${IP}${RESET}"
[[ -n "$CITY$REGION$COUNTRY" ]] && echo -e "  ${BRIGHT_WHITE}${BOLD}Location${RESET}   ${WHITE}${CITY}${CITY:+, }${REGION}${REGION:+, }${COUNTRY}${CC:+ (${CC})}${RESET}"
[[ -n "$POSTAL" ]] && echo -e "  ${BRIGHT_WHITE}${BOLD}Postal${RESET}     ${WHITE}${POSTAL}${RESET}"
[[ -n "$LAT" ]]    && echo -e "  ${BRIGHT_WHITE}${BOLD}Coords${RESET}     ${WHITE}${LAT}, ${LON}${RESET}"
[[ -n "$TZ" ]]     && echo -e "  ${BRIGHT_WHITE}${BOLD}Timezone${RESET}   ${WHITE}${TZ}${RESET}"
[[ -n "$ORG" ]]    && echo -e "  ${BRIGHT_WHITE}${BOLD}ISP/Org${RESET}    ${WHITE}${ORG}${RESET}"
[[ -n "$ASN" ]]    && echo -e "  ${BRIGHT_WHITE}${BOLD}ASN${RESET}        ${WHITE}${ASN}${RESET}"

echo
