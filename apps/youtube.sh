#!/usr/bin/env bash

# name: youtube
# description: YouTube player

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT_DIR/core/index.sh"

QUERY=$(ask "Search YouTube")
clear

QUERY_DISPLAY="${QUERY//%20/ }"
QUERY_DISPLAY="${QUERY_DISPLAY//+/ }"

RESPONSE=$(fetch "https://lokixer.koyeb.app/search/youtube?q=$QUERY")

titles=()
urls=()
durations=()
authors=()
views=()


while IFS= read -r line; do
    titles+=("$line")
done < <(
    echo "$RESPONSE" |
    grep -o '"title":"[^"]*"' |
    sed 's/"title":"//;s/"//g'
)

while IFS= read -r line; do
    urls+=("$line")
done < <(
    echo "$RESPONSE" |
    grep -o '"url":"[^"]*"' |
    sed 's/"url":"//;s/"//g'
)


while IFS= read -r line; do
    durations+=("$line")
done < <(
    echo "$RESPONSE" |
    grep -o '"duration":"[^"]*"' |
    sed 's/"duration":"//;s/"//g'
)


while IFS= read -r line; do
    authors+=("$line")
done < <(
    echo "$RESPONSE" |
    grep -o '"author":"[^"]*"' |
    sed 's/"author":"//;s/"//g'
)

while IFS= read -r line; do
    views+=("$line")
done < <(
    echo "$RESPONSE" |
    grep -o '"views":"[^"]*"' |
    sed 's/"views":"//;s/"//g'
)

if [[ ${#titles[@]} -eq 0 ]]; then
    echo "❌ No results found"
    exit 1
fi

selected=0

draw_menu() {

    tput cup 0 0
    tput ed

    echo -e "\033[1;31m"
    echo "██╗   ██╗ ██████╗ ██╗   ██╗████████╗██╗   ██╗██████╗ ███████╗"
    echo "╚██╗ ██╔╝██╔═══██╗██║   ██║╚══██╔══╝██║   ██║██╔══██╗██╔════╝"
    echo " ╚████╔╝ ██║   ██║██║   ██║   ██║   ██║   ██║██████╔╝█████╗  "
    echo "  ╚██╔╝  ██║   ██║██║   ██║   ██║   ██║   ██║██╔══██╗██╔══╝  "
    echo "   ██║   ╚██████╔╝╚██████╔╝   ██║   ╚██████╔╝██████╔╝███████╗"
    echo "   ╚═╝    ╚═════╝  ╚═════╝    ╚═╝    ╚═════╝ ╚═════╝ ╚══════╝"
    echo -e "\033[0m"

    echo -e "\033[1;36mSearch:\033[0m $QUERY_DISPLAY"
    echo ""

    local term_lines
    term_lines=$(tput lines)

    local header_lines=9
    local footer_lines=3
    local item_lines=3

    local visible=$(( (term_lines - header_lines - footer_lines) / item_lines ))

    [[ $visible -lt 1 ]] && visible=1

    local total=${#titles[@]}

    local half=$(( visible / 2 ))
    local offset=$(( selected - half ))

    [[ $offset -lt 0 ]] && offset=0
    [[ $(( offset + visible )) -gt $total ]] && offset=$(( total - visible ))
    [[ $offset -lt 0 ]] && offset=0

    local end=$(( offset + visible ))

    [[ $end -gt $total ]] && end=$total

    if [[ $offset -gt 0 ]]; then
        echo -e "   \033[0;90m↑ $offset more above\033[0m"
    fi

    for (( i=offset; i<end; i++ )); do

        if [[ $i -eq $selected ]]; then
            echo -e "\033[1;32m▶ ${titles[$i]}\033[0m"
            echo -e "   \033[0;90m👤 ${authors[$i]}\033[0m"
            echo -e "   \033[0;90m⏱ ${durations[$i]}   👁 ${views[$i]}\033[0m"
            echo ""
        else
            echo -e "\033[0;37m  ${titles[$i]}\033[0m"
            echo -e "   \033[0;90m${authors[$i]} • ${durations[$i]}\033[0m"
            echo ""
        fi

    done

    local remaining=$(( total - end ))

    if [[ $remaining -gt 0 ]]; then
        echo -e "   \033[0;90m↓ $remaining more below\033[0m"
    fi

    echo -e "\033[0;90m─────────────────────────────────────\033[0m"
    echo -e "\033[0;90m↑ ↓ navigate • ENTER play • q quit   [$(( selected + 1 ))/$total]\033[0m"
}

draw_player_menu() {

    local options=("Stop Playback" "Back To Menu" "Quit")
    local player_selected=0

    while true; do

        clear

        if ! kill -0 "$PLAYER_PID" 2>/dev/null; then
            echo ""
            echo "Playback finished."
            sleep 1
            break
        fi

        echo -e "\033[1;31m"
        echo "██╗   ██╗ ██████╗ ██╗   ██╗████████╗██╗   ██╗██████╗ ███████╗"
        echo "╚██╗ ██╔╝██╔═══██╗██║   ██║╚══██╔══╝██║   ██║██╔══██╗██╔════╝"
        echo " ╚████╔╝ ██║   ██║██║   ██║   ██║   ██║   ██║██████╔╝█████╗  "
        echo "  ╚██╔╝  ██║   ██║██║   ██║   ██║   ██║   ██║██╔══██╗██╔══╝  "
        echo "   ██║   ╚██████╔╝╚██████╔╝   ██║   ╚██████╔╝██████╔╝███████╗"
        echo "   ╚═╝    ╚═════╝  ╚═════╝    ╚═╝    ╚═════╝ ╚═════╝ ╚══════╝"
        echo -e "\033[0m"

        echo ""
        echo -e "\033[1;32m▶ Now Playing:\033[0m"
        echo "${titles[$selected]}"
        echo ""

        for (( i=0; i<${#options[@]}; i++ )); do

            if [[ $i -eq $player_selected ]]; then
                echo -e "\033[1;32m▶ ${options[$i]}\033[0m"
            else
                echo -e "\033[0;37m  ${options[$i]}\033[0m"
            fi

        done

        echo ""
        echo -e "\033[0;90m↑ ↓ navigate • ENTER select\033[0m"

        IFS= read -rsn1 key

        if [[ $key == $'\x1b' ]]; then

            IFS= read -rsn1 -t 0.1 key2

            if [[ $key2 == '[' ]]; then

                IFS= read -rsn1 -t 0.1 key3

                case $key3 in

                    'A')
                        ((player_selected--))
                        [[ $player_selected -lt 0 ]] && player_selected=$((${#options[@]} - 1))
                        ;;

                    'B')
                        ((player_selected++))
                        [[ $player_selected -ge ${#options[@]} ]] && player_selected=0
                        ;;

                esac

            fi

            continue
        fi

        if [[ $key == "" || $key == $'\n' || $key == $'\r' ]]; then

            case $player_selected in

                0)
                    kill "$PLAYER_PID" 2>/dev/null
                    echo ""
                    echo "Stopped."
                    sleep 1
                    break
                    ;;

                1)
                    break
                    ;;

                2)
                    kill "$PLAYER_PID" 2>/dev/null
                    clear
                    tput cnorm
                    tput rmcup
                    exit 0
                    ;;

            esac

        fi

    done
}

tput civis
trap 'tput cnorm; tput rmcup; exit' INT TERM EXIT

tput smcup
clear

while true; do

    draw_menu

    IFS= read -rsn1 key

    if [[ $key == $'\x1b' ]]; then

        IFS= read -rsn1 -t 0.1 key2

        if [[ $key2 == '[' ]]; then

            IFS= read -rsn1 -t 0.1 key3

            case $key3 in

                'A')
                    ((selected--))
                    [[ $selected -lt 0 ]] && selected=$((${#titles[@]} - 1))
                    ;;

                'B')
                    ((selected++))
                    [[ $selected -ge ${#titles[@]} ]] && selected=0
                    ;;

            esac

        fi

        continue
    fi

   
    if [[ $key == "" || $key == $'\n' || $key == $'\r' ]]; then

        tput rmcup
        tput cnorm

        mpv "${urls[$selected]}" >/dev/null 2>&1 &
        PLAYER_PID=$!

        draw_player_menu

        tput smcup
        tput civis

        continue
    fi

   
    if [[ $key == "q" || $key == "Q" ]]; then
        break
    fi

done

tput cnorm
tput rmcup
clear
