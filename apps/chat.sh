#!/usr/bin/env bash

# name: chat
# description: Create or join a room and chat live with others

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT_DIR/core/index.sh"

CHAT_API="https://lokixer.koyeb.app/chat"
CONFIG_FILE="$HOME/.reo_chat_username"
POLL_INTERVAL=8
POLL_PID=""

json_escape() {
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

get_username() {
    if [[ -f "$CONFIG_FILE" ]]; then
        cat "$CONFIG_FILE"
    else
        local name
        name=$(ask "Choose a username")
        echo "$name" > "$CONFIG_FILE"
        echo "$name"
    fi
}

stop_poller() {
    [[ -n "$POLL_PID" ]] && kill "$POLL_PID" 2>/dev/null
    POLL_PID=""
}

on_interrupt() {
    stop_poller
    echo
    consolog bright_black "bye"
    exit 0
}
trap on_interrupt INT TERM

create_room() {
    clear
    echo
    consolog bright_yellow "Creating room..."

    RESPONSE=$(fetch -X POST -U "$CHAT_API/room/create" -D "{\"username\":\"$(json_escape "$USERNAME")\"}")
    STATUS=$(echo "$RESPONSE" | grep -o '"status":[^,}]*' | cut -d':' -f2)
    ROOM_ID=$(echo "$RESPONSE" | grep -oP '"roomId":"\K[^"]*')

    if [[ "$STATUS" != "true" || -z "$ROOM_ID" ]]; then
        consolog bright_red "Failed to create room. Try again."
        echo
        read -rsn1 -p "Press any key to continue..."
        return
    fi

    clear
    echo
    consolog bright_green "╔══════════════════════════════╗"
    consolog bright_green "║        ROOM CREATED          ║"
    consolog bright_green "╚══════════════════════════════╝"
    echo
    consolog bright_white "Room ID: ${BOLD}${ROOM_ID}"
    consolog bright_black "Share this code so others can join."
    echo
    read -rsn1 -p "Press any key to enter the room..."

    enter_room "$ROOM_ID"
}

join_room() {
    clear
    echo
    local room_id
    room_id=$(ask "Room ID")
    room_id="${room_id^^}"

    consolog bright_yellow "Checking room..."

    RESPONSE=$(fetch "$CHAT_API/room/$room_id")
    STATUS=$(echo "$RESPONSE" | grep -o '"status":[^,}]*' | cut -d':' -f2)

    if [[ "$STATUS" != "true" ]]; then
        clear
        echo
        consolog bright_red "╔══════════════════════════════╗"
        consolog bright_red "║        ROOM NOT FOUND        ║"
        consolog bright_red "╚══════════════════════════════╝"
        echo
        consolog bright_red "No room exists with ID: $room_id"
        echo
        read -rsn1 -p "Press any key to go back..."
        return
    fi

    enter_room "$room_id"
}

poll_loop() {
    local room_id="$1"
    local last_id=0
    local response

    while true; do
        response=$(fetch "$CHAT_API/room/$room_id/messages?since=$last_id" 2>/dev/null)

        if [[ -n "$response" ]]; then
            while IFS= read -r item; do
                [[ -z "$item" ]] && continue

                local id user msg time
                id=$(echo "$item" | grep -oP '"id":\K[0-9]+')
                user=$(echo "$item" | grep -oP '"username":"\K[^"]*')
                msg=$(echo "$item" | grep -oP '"message":"\K[^"]*')
                time=$(echo "$item" | grep -oP '"time":"\K[^"]*')

                [[ -z "$id" ]] && continue

                echo -ne "\r\033[K" > /dev/tty
                echo -e "${BRIGHT_BLACK}[$time]${RESET} ${BRIGHT_CYAN}${user}${RESET}: ${WHITE}${msg}${RESET}" > /dev/tty
                echo -ne "${BRIGHT_GREEN}${USERNAME} > ${RESET}" > /dev/tty

                [[ "$id" -gt "$last_id" ]] && last_id=$id
            done < <(echo "$response" | grep -oP '\{"id":[0-9]+,"username":"[^"]*","message":"[^"]*","time":"[^"]*"\}')
        fi

        sleep "$POLL_INTERVAL"
    done
}

enter_room() {
    local room_id="$1"

    clear
    echo
    consolog bright_yellow "╔══════════════════════════════╗"
    consolog bright_yellow "║           ROOM CHAT          ║"
    consolog bright_yellow "╚══════════════════════════════╝"
    echo
    consolog bright_black "Room: $room_id   |   You: $USERNAME"
    consolog bright_black "/leave  back to menu   /name <new>  change name"
    echo

    poll_loop "$room_id" &
    POLL_PID=$!

    while true; do
        echo -ne "${BRIGHT_GREEN}${USERNAME} > ${RESET}" > /dev/tty
        read -r MSG < /dev/tty

        [[ -z "$MSG" ]] && continue

        if [[ "$MSG" == "/leave" ]]; then
            stop_poller
            return
        fi

        if [[ "$MSG" == /name\ * ]]; then
            local new_name="${MSG#/name }"
            new_name=$(echo "$new_name" | sed 's/^ *//;s/ *$//')
            if [[ -n "$new_name" ]]; then
                USERNAME="$new_name"
                echo "$USERNAME" > "$CONFIG_FILE"
                consolog bright_black "name changed to $USERNAME" > /dev/tty
            fi
            continue
        fi

        BODY="{\"username\":\"$(json_escape "$USERNAME")\",\"message\":\"$(json_escape "$MSG")\"}"
        fetch -X POST -U "$CHAT_API/room/$room_id/messages" -D "$BODY" > /dev/null
    done
}

USERNAME=$(get_username)
options=("Create Room" "Join Room" "Exit")
selected=0

draw_menu() {
    clear
    echo
    consolog bright_cyan "╔══════════════════════════════╗"
    consolog bright_cyan "║           REO CHAT           ║"
    consolog bright_cyan "╚══════════════════════════════╝"
    echo
    consolog bright_black "Logged in as: $USERNAME"
    echo

    for i in "${!options[@]}"; do
        if [[ "$i" -eq "$selected" ]]; then
            if [[ "${options[$i]}" == "Exit" ]]; then
                echo -e "  ${RED}${BOLD}❯ ${options[$i]}${RESET}"
            else
                echo -e "  ${GREEN}${BOLD}❯ ${options[$i]}${RESET}"
            fi
        else
            echo -e "    ${GRAY}${options[$i]}${RESET}"
        fi
    done

    echo
    consolog bright_black "Use ↑ ↓ arrows and press ENTER"
}

while true; do
    draw_menu
    read -rsn1 key

    if [[ $key == $'\x1b' ]]; then
        read -rsn2 key
        case $key in
            '[A') ((selected--)); [[ $selected -lt 0 ]] && selected=$((${#options[@]} - 1)) ;;
            '[B') ((selected++)); [[ $selected -ge ${#options[@]} ]] && selected=0 ;;
        esac
    elif [[ $key == "" ]]; then
        case "${options[$selected]}" in
            "Create Room") create_room ;;
            "Join Room") join_room ;;
            "Exit") clear; exit 0 ;;
        esac
    fi
done
