# name: torrent
# alias: tor
# description: Search torrents via The Pirate Bay

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT_DIR/core/index.sh"
API="https://apibay.org/q.php"


urlencode() {
    local string="$*" encoded="" i c
    for (( i=0; i<${#string}; i++ )); do
        c="${string:$i:1}"
        case "$c" in
            [a-zA-Z0-9._~-]) encoded+="$c" ;;
            " ") encoded+="+" ;;
            *) encoded+=$(printf '%%%02X' "'$c") ;;
        esac
    done
    echo "$encoded"
}

format_size() {
    local bytes=$1
    bytes=$(echo "$bytes" | tr -d '[:space:]')
    [[ -z "$bytes" || "$bytes" == "0" ]] && echo "0 B" && return

    local units=("B" "KB" "MB" "GB" "TB")
    local i=0

    while [[ $bytes -ge 1024 && $i -lt 4 ]]; do
        bytes=$(( bytes / 1024 ))
        (( i++ ))
    done

    echo "$bytes ${units[$i]}"
}



parse_results() {
    local json="$1"
    echo "$json" | sed 's/},{/}\n{/g' | while IFS= read -r obj; do
        local name id info_hash seeders leechers size username

        name=$(echo "$obj"      | grep -o '"name":"[^"]*"'      | head -1 | cut -d'"' -f4)
        id=$(echo "$obj"        | grep -o '"id":"[^"]*"'         | head -1 | cut -d'"' -f4)
        info_hash=$(echo "$obj" | grep -o '"info_hash":"[^"]*"'  | head -1 | cut -d'"' -f4)
        seeders=$(echo "$obj"   | grep -o '"seeders":"[^"]*"'    | head -1 | cut -d'"' -f4)
        leechers=$(echo "$obj"  | grep -o '"leechers":"[^"]*"'   | head -1 | cut -d'"' -f4)
        size=$(echo "$obj"      | grep -o '"size":"[^"]*"'       | head -1 | cut -d'"' -f4)
        username=$(echo "$obj"  | grep -o '"username":"[^"]*"'   | head -1 | cut -d'"' -f4)

        # skip bad/empty entries
        [[ -z "$name" || -z "$info_hash" ]] && continue
        [[ "$id" == "0" ]] && continue
        [[ "$info_hash" == "0000000000000000000000000000000000000000" ]] && continue
        [[ -z "$seeders" || "$seeders" == "0" ]] && continue

        echo "${seeders}|${name}|${leechers}|${size}|${username}|${info_hash}"
    done
}


do_search() {
    local query="$*"
    local encoded; encoded=$(urlencode "$query")

    clear
    echo ""
    consolog bright_cyan "  ┌─────────────────────────────────────────────────┐"
    consolog bright_cyan "  │  REO // torrent search                          │"
    consolog bright_cyan "  └─────────────────────────────────────────────────┘"
    echo ""
    echo -e "  ${YELLOW}searching:${RESET}  ${WHITE}$query${RESET}"
    echo -e "  ${BRIGHT_BLACK}╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌${RESET}"
    echo ""

    local response
    response=$(fetch "$API?q=$encoded")

    if [[ $? -ne 0 || -z "$response" || "$response" == "[]" ]]; then
        consolog error "  ✗  request failed or no results"
        echo ""
        return 1
    fi

    
    local raw_list
    raw_list=$(parse_results "$response" | sort -t'|' -k1 -rn | head -10)

    if [[ -z "$raw_list" ]]; then
        consolog warn "  ⚠  no results found for: $query"
        echo ""
        return 0
    fi

    TITLES=()
    SEEDERS=()
    LEECHERS=()
    SIZES=()
    UPLOADERS=()
    HASHES=()

    while IFS='|' read -r seeders name leechers size username info_hash; do
        TITLES+=("$name")
        SEEDERS+=("$seeders")
        LEECHERS+=("$leechers")
        SIZES+=("$(format_size "$size")")
        UPLOADERS+=("$username")
        HASHES+=("$info_hash")
    done <<< "$raw_list"

    browse_results
}

browse_results() {
    local sel=0
    local total=${#TITLES[@]}

    draw_list() {
        clear
        echo ""
        consolog bright_cyan "  ┌─────────────────────────────────────────────────┐"
        consolog bright_cyan "  │  REO // torrent results  (top 10 by seeders)    │"
        consolog bright_cyan "  └─────────────────────────────────────────────────┘"
        echo ""

        for i in "${!TITLES[@]}"; do
            local title="${TITLES[$i]}"
            local seed="${SEEDERS[$i]}"
            local size="${SIZES[$i]}"
            local num=$(( i + 1 ))

            [[ ${#title} -gt 44 ]] && title="${title:0:44}..."

            if [[ $i -eq $sel ]]; then
                echo -e "  ${CYAN}❯ ${num}.${RESET}  ${WHITE}$(printf '%-48s' "$title")${RESET}  ${GREEN}▲${seed}${RESET}  ${BRIGHT_BLACK}${size}${RESET}"
            else
                echo -e "  ${BRIGHT_BLACK}  ${num}.  $(printf '%-48s' "$title")  ▲${seed}  ${size}${RESET}"
            fi
        done

        echo ""
        echo -e "  ${BRIGHT_BLACK}╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌${RESET}"
        echo -e "  ${BRIGHT_BLACK}↑ ↓ navigate   ENTER details   N new search   Q quit${RESET}"
        echo ""
    }

    show_detail() {
        local i=$1
        clear
        echo ""
        consolog bright_cyan "  ┌─────────────────────────────────────────────────┐"
        consolog bright_cyan "  │  REO // torrent detail                          │"
        consolog bright_cyan "  └─────────────────────────────────────────────────┘"
        echo ""
        echo -e "  ${WHITE}${TITLES[$i]}${RESET}"
        echo ""
        echo -e "  ${BRIGHT_BLACK}seeders      ${RESET}  ${GREEN}${SEEDERS[$i]}${RESET}"
        echo -e "  ${BRIGHT_BLACK}leechers     ${RESET}  ${RED}${LEECHERS[$i]}${RESET}"
        echo -e "  ${BRIGHT_BLACK}size         ${RESET}  ${YELLOW}${SIZES[$i]}${RESET}"
        echo -e "  ${BRIGHT_BLACK}uploader     ${RESET}  ${CYAN}${UPLOADERS[$i]}${RESET}"
        echo ""
        echo -e "  ${BRIGHT_BLACK}╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌${RESET}"
        echo ""
        echo -e "  ${BRIGHT_BLACK}magnet:${RESET}        ${BRIGHT_BLACK}magnet:?xt=urn:btih:${HASHES[$i]}${RESET}"
        echo ""
        echo -e "  ${BRIGHT_BLACK}torrent file:${RESET}  ${GREEN}https://itorrents.org/torrent/${HASHES[$i]}.torrent${RESET}"
        echo ""
        echo -e "  ${BRIGHT_BLACK}╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌${RESET}"
        echo -e "  ${BRIGHT_BLACK}press any key to go back...${RESET}"
        read -n1 -s
    }

    while true; do
        draw_list
        read -rsn1 key

        if [[ $key == $'\x1b' ]]; then
            read -rsn2 key
            case $key in
                '[A') (( sel-- )); [[ $sel -lt 0 ]] && sel=$(( total - 1 )) ;;
                '[B') (( sel++ )); [[ $sel -ge $total ]] && sel=0 ;;
            esac
        elif [[ "$key" == "q" || "$key" == "Q" ]]; then
            clear; exit 0
        elif [[ "$key" == "n" || "$key" == "N" ]]; then
            return 0
        elif [[ $key == "" ]]; then
            show_detail "$sel"
        fi
    done
}

if [[ -n "$*" ]]; then
    do_search "$*"
    exit 0
fi

while true; do
    clear
    echo ""
    consolog bright_cyan "  ┌─────────────────────────────────────────────────┐"
    consolog bright_cyan "  │  REO // torrent                                 │"
    consolog bright_cyan "  │  search ThePirateBay  •  blank to exit          │"
    consolog bright_cyan "  └─────────────────────────────────────────────────┘"
    echo ""
    echo -e "  ${BRIGHT_BLACK}╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌${RESET}"
    echo ""

    query=$(ask "search")
    [[ -z "$query" ]] && clear && exit 0

    query_display=$(decodeURIComponent "$query")
    do_search "$query_display"
done
