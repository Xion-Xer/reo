#!/usr/bin/env bash

# name: tempmail
# description: Temp mail generator with inbox viewer

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT_DIR/core/index.sh"

API="https://lokixer.koyeb.app/tools/tempmail"

options=("new mail" "check mail" "exit")
selected=0
CURRENT_EMAIL=""


draw_menu() {
    clear
    echo ""
    echo -e "${CYAN}${BOLD}╔══════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║         TEMP MAIL CLI        ║${RESET}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════╝${RESET}"
    echo ""

    if [[ -n "$CURRENT_EMAIL" ]]; then
        echo -e "${GREEN}📧 Active: ${WHITE}$CURRENT_EMAIL${RESET}"
    else
        echo -e "${YELLOW}⏳ Generating email...${RESET}"
    fi

    echo ""

    for i in "${!options[@]}"; do
        if [[ "$i" -eq "$selected" ]]; then
            echo -e "  ${GREEN}${BOLD}❯ ${options[$i]}${RESET}"
        else
            echo -e "    ${GRAY}${options[$i]}${RESET}"
        fi
    done

    echo ""
    echo -e "${GRAY}Use ↑ ↓ arrows and ENTER${RESET}"
    echo ""
}


show_inbox() {
    local RESPONSE="$1"

    clear
    echo ""
    echo -e "${GREEN}${BOLD}╔══════════════════════════════╗${RESET}"
    echo -e "${GREEN}${BOLD}║           INBOX              ║${RESET}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════╝${RESET}"
    echo ""
    echo -e "${DIM}📬 ${CURRENT_EMAIL}${RESET}"
    echo ""

    DATA=$(echo "$RESPONSE" | grep -o '"result":\[.*\]' | sed 's/"result"://')

    if [[ -z "$DATA" || "$DATA" == "[]" ]]; then
        echo -e "${YELLOW}📭 No messages yet.${RESET}"
    else
       
        echo "$RESPONSE" | grep -oP '"@id"\s*:\s*"[^"]+.*?(?="@id"|\]\s*}|$)' | while IFS= read -r ENTRY; do

            FROM=$(echo "$ENTRY"  | grep -oP '"address"\s*:\s*"\K[^"]+' | head -1)
            NAME=$(echo "$ENTRY"  | grep -oP '"name"\s*:\s*"\K[^"]+' | head -1)
            SUBJ=$(echo "$ENTRY"  | grep -oP '"subject"\s*:\s*"\K[^"]+')
            INTRO=$(echo "$ENTRY" | grep -oP '"intro"\s*:\s*"\K[^"]+')
            DATE=$(echo "$ENTRY"  | grep -oP '"createdAt"\s*:\s*"\K[^"]+')

            echo -e "${CYAN}────────────────────────────────${RESET}"
            if [[ -n "$NAME" ]]; then
                echo -e "${WHITE}From   :${RESET} $NAME <$FROM>"
            elif [[ -n "$FROM" ]]; then
                echo -e "${WHITE}From   :${RESET} $FROM"
            fi
            [[ -n "$SUBJ"  ]] && echo -e "${WHITE}Subject:${RESET} $SUBJ"
            [[ -n "$DATE"  ]] && echo -e "${WHITE}Date   :${RESET} $DATE"
            [[ -n "$INTRO" ]] && echo -e "${WHITE}Preview:${RESET} $INTRO"
        done
        echo -e "${CYAN}────────────────────────────────${RESET}"
    fi

    echo ""
    echo -e "${DIM}Press any key to return...${RESET}"
    read -rsn1
}


create_email() {
    local RESPONSE
    RESPONSE=$(fetch "$API")
    local EMAIL
    EMAIL=$(echo "$RESPONSE" | grep -o '"result":"[^"]*"' | cut -d':' -f2 | tr -d '"')

    if [[ -n "$EMAIL" ]]; then
        CURRENT_EMAIL="$EMAIL"
    else
        echo -e "${RED}Failed to generate email.${RESET}"
        sleep 1
    fi
}


create_email


while true; do

    draw_menu
    read -rsn1 key

    if [[ $key == $'\x1b' ]]; then
        read -rsn2 key
        case $key in
            '[A')
                ((selected--))
                [[ $selected -lt 0 ]] && selected=$((${#options[@]} - 1))
                ;;
            '[B')
                ((selected++))
                [[ $selected -ge ${#options[@]} ]] && selected=0
                ;;
        esac
    fi

    if [[ $key == "" ]]; then
        choice="${options[$selected]}"

        # EXIT
        if [[ "$choice" == "exit" ]]; then
            clear
            exit 0
        fi

        
        if [[ "$choice" == "new mail" ]]; then
            create_email
        fi

        
        if [[ "$choice" == "check mail" ]]; then
            if [[ -z "$CURRENT_EMAIL" ]]; then
                clear
                echo -e "${RED}No email created yet.${RESET}"
                sleep 1
                continue
            fi

            clear
            echo -e "${DIM}Fetching inbox...${RESET}"

            RESPONSE=$(fetch -U "$API" -D "$(printf '{"q":"%s"}' "$CURRENT_EMAIL")")
            show_inbox "$RESPONSE"
        fi

    fi

done
