#!/usr/bin/env bash

# name: news
# description: Fetch latest news headlines

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT_DIR/core/index.sh"
names=("manorama" "mathrubhumi" "mediaone" "twentyfour" "exit")
selected=0

draw_menu() {

    clear

    echo ""
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║         NEWS SELECT MENU           ║${RESET}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════╝${RESET}"
    echo ""

    for i in "${!names[@]}"; do

        if [[ "$i" -eq "$selected" ]]; then

           
            if [[ "${names[$i]}" == "exit" ]]; then
                echo -e "  ${RED}${BOLD}❯ ${names[$i]}${RESET}"
            else
                
                echo -e "  ${GREEN}${BOLD}❯ ${names[$i]}${RESET}"
            fi

        else
            echo -e "    ${GRAY}${names[$i]}${RESET}"
        fi

    done

    echo ""
    echo -e "  ${GRAY}Use ↑ ↓ arrows and press ENTER${RESET}"
    echo ""

}

show_news() {

    RESPONSE="$1"

    clear

    echo ""
    echo -e "${GREEN}${BOLD}╔════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}${BOLD}║          LATEST HEADLINES          ║${RESET}"
    echo -e "${GREEN}${BOLD}╚════════════════════════════════════╝${RESET}"
    echo ""

    # Extract array content
    DATA=$(echo "$RESPONSE" | sed 's/.*"result":\[//')
    DATA=$(echo "$DATA" | sed 's/\]}.*//')

    IFS='{' read -ra ITEMS <<< "$DATA"

    count=0

    for item in "${ITEMS[@]}"; do

        title=$(echo "$item" | grep -oP '"title":"\K([^"]+)')
        link=$(echo "$item" | grep -oP '"link":"\K([^"]+)')
        date=$(echo "$item" | grep -oP '"date":"\K([^"]+)')
        image=$(echo "$item" | grep -oP '"image":"\K([^"]+)')
        summary=$(echo "$item" | grep -oP '"summary":"\K([^"]+)')

        [[ -z "$title" ]] && continue

        ((count++))

        echo -e "${YELLOW}${BOLD}[$count]${RESET} ${WHITE}${BOLD}$title${RESET}"

        if [[ -n "$summary" ]]; then
            echo ""
            echo -e "    ${GRAY}$summary${RESET}"
        fi

        echo ""

        if [[ -n "$date" ]]; then
            echo -e "    ${CYAN}📅 $date${RESET}"
        fi

        if [[ -n "$image" ]]; then
            echo -e "    ${MAGENTA}🖼️  $image${RESET}"
        fi

        if [[ -n "$link" ]]; then
            echo -e "    ${GRAY}🔗 $link${RESET}"
        fi

        echo ""
        echo -e "${DIM}────────────────────────────────────${RESET}"
        echo ""

    done

    echo -e "${DIM}Press any key to return to menu...${RESET}"
    read -rsn1

}


while true; do

    draw_menu

    read -rsn1 key

  
    if [[ $key == $'\x1b' ]]; then

        read -rsn2 key

        case $key in

            '[A')
                ((selected--))
                [[ $selected -lt 0 ]] && selected=$((${#names[@]} - 1))
            ;;

            '[B')
                ((selected++))
                [[ $selected -ge ${#names[@]} ]] && selected=0
            ;;

        esac

   
    elif [[ $key == "" ]]; then

        chosen="${names[$selected]}"

        
        if [[ "$chosen" == "exit" ]]; then
            clear
            exit 0
        fi

        clear

        echo ""
        echo -e "${GREEN}${BOLD}[ SELECTED ]${RESET} ${WHITE}${BOLD}$chosen${RESET}"
        echo ""

        RESPONSE=$(fetch "https://lokixer.koyeb.app/news/$chosen")

        show_news "$RESPONSE"

    fi

done
