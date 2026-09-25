#!/usr/bin/env bash

# name: homograph
# description: Generate Unicode homograph variants

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

source "$ROOT_DIR/core/index.sh"
source "$ROOT_DIR/core/confusables.sh"

RESET="\033[0m"
BOLD="\033[1m"

RED="\033[38;5;196m"
GREEN="\033[38;5;82m"
YELLOW="\033[38;5;220m"
CYAN="\033[38;5;51m"
WHITE="\033[97m"
GRAY="\033[38;5;240m"

clear

echo
echo -e "${CYAN}${BOLD}  ╔══════════════════════════════════╗${RESET}"
echo -e "${CYAN}${BOLD}  ║          HOMOGRAPH GEN           ║${RESET}"
echo -e "${CYAN}${BOLD}  ╚══════════════════════════════════╝${RESET}"
echo

read -r -p "  Enter domain/text: " DOMAIN

DOMAIN="${DOMAIN#"${DOMAIN%%[![:space:]]*}"}"
DOMAIN="${DOMAIN%"${DOMAIN##*[![:space:]]}"}"

DOMAIN="${DOMAIN#http://}"
DOMAIN="${DOMAIN#https://}"
DOMAIN="${DOMAIN#www.}"
DOMAIN="${DOMAIN%/}"

if [[ -z "$DOMAIN" ]]; then
    echo
    echo -e "  ${RED}${BOLD}[!] Input cannot be empty.${RESET}"
    echo
    exit 1
fi

while true; do
    echo
    read -r -p "  How many variants do you want: " AMOUNT

    if [[ "$AMOUNT" =~ ^[1-9][0-9]*$ ]]; then
        break
    fi

    echo -e "  ${RED}${BOLD}[!] Enter a positive number.${RESET}"
done

HOST="$DOMAIN"
TLD=""
IS_DOMAIN=false

if [[ "$DOMAIN" == *.* ]]; then
    possible_host="${DOMAIN%.*}"
    possible_tld="${DOMAIN##*.}"

    if [[ -n "$possible_host" && -n "$possible_tld" ]]; then
        if [[ "$possible_tld" =~ ^[A-Za-z]+$ ]]; then
            HOST="$possible_host"
            TLD="$possible_tld"
            IS_DOMAIN=true
        fi
    fi
fi

echo

if [[ "$IS_DOMAIN" == true ]]; then
    echo -e "  ${GRAY}Type${RESET}       ${GREEN}Domain${RESET}"
    echo -e "  ${GRAY}Input${RESET}      ${WHITE}${DOMAIN}${RESET}"
    echo -e "  ${GRAY}Host${RESET}       ${WHITE}${HOST}${RESET}"
    echo -e "  ${GRAY}TLD${RESET}        ${WHITE}.${TLD}${RESET}"
else
    echo -e "  ${GRAY}Type${RESET}       ${YELLOW}Text${RESET}"
    echo -e "  ${GRAY}Input${RESET}      ${WHITE}${DOMAIN}${RESET}"
fi

echo -e "  ${GRAY}Requested${RESET}  ${WHITE}${AMOUNT}${RESET}"
echo

echo -e "  ${YELLOW}${BOLD}[+] Generating...${RESET}"
echo

results=()

while IFS= read -r variant; do
    [[ -n "$variant" ]] || continue

    if [[ "$IS_DOMAIN" == true ]]; then
        results+=("${variant}.${TLD}")
    else
        results+=("$variant")
    fi
done < <(generate_confusables "$HOST" "$AMOUNT")

COUNT="${#results[@]}"

if [[ "$COUNT" -eq 0 ]]; then
    echo
    echo -e "  ${RED}${BOLD}[!] No variants generated.${RESET}"
    echo
    exit 1
fi

echo -e "  ${GREEN}${BOLD}[✓] Generated ${COUNT} variants${RESET}"
echo

echo -e "  ${GRAY}────────────────────────────────────────${RESET}"

INDEX=1

for variant in "${results[@]}"; do
    echo -e "  ${GRAY}${INDEX}.${RESET} ${WHITE}${variant}${RESET}"
    ((INDEX++))
done

echo -e "  ${GRAY}────────────────────────────────────────${RESET}"
echo
echo -e "  ${GREEN}${BOLD}[✓] Done${RESET}"
echo

read -n 1 -s -r -p "  Press any key to exit..."
echo
