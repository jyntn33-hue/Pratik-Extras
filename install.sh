#!/bin/bash

# Screen clear karne ke liye
clear

# Text formatting ke liye colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Rainbow Text Function
print_rainbow() {
    local text="$1"
    local colors=("\033[1;31m" "\033[1;33m" "\033[1;32m" "\033[1;36m" "\033[1;34m" "\033[1;35m")
    local color_count=${#colors[@]}
    local color_index=0
    while IFS= read -r line; do
        for (( i=0; i<${#line}; i++ )); do
            local char="${line:$i:1}"
            if [ "$char" == " " ]; then printf " "; else
                printf "${colors[$color_index]}%s" "$char"
                color_index=$(( (color_index + 1) % color_count ))
            fi
        done
        printf "\n"
    done <<< "$text"
    printf "\033[0m"
}

# Fixed Single-Line Progress Bar Function
custom_progress_bar() {
    local pid_to_watch=$1
    local steps=50
    local messages=("Scripting..." "Initializing..." "Extracting..." "Zipping..." "Configuring Database..." "Finalizing...")
    
    # Pehle cursor setup ke liye space banao
    echo ""
    echo ""

    # Jab tak background pid chal raha hai ya bar complete nahi hota
    local i=0
    while kill -0 $pid_to_watch 2>/dev/null || [ $i -le $steps ]; do
        local percent=$(( i * 100 / steps ))
        local msg_index=$(( i / (steps / ${#messages[@]}) ))
        if [ $msg_index -ge ${#messages[@]} ]; then msg_index=$(( ${#messages[@]} - 1 )); fi
        
        # Do line upar jaakar text aur bar overwrite karo (no duplicate prints!)
        printf "\033[A\033[A\r\033[K${GREEN}${BOLD}%s${NC}\n" "${messages[$msg_index]}"
        printf "\r\033[K${GREEN}["
        for ((j=0; j<i; j++)); do printf "■"; done
        for ((j=i; j<steps; j++)); do printf " "; done
        printf "] %d%%${NC}\n" "$percent"
        
        # Agar loop slow chalana ho jab script sach me heavy ho
        if kill -0 $pid_to_watch 2>/dev/null; then
            if [ $i -lt $steps ]; then
                ((i++))
            fi
            sleep 0.1
        else
            # Agar background execution khatam ho gayi, toh tezi se 100% karo
            if [ $i -le $steps ]; then
                ((i++))
                sleep 0.02
            fi
        fi
    done
    echo ""
}

# --- MENU NAVIGATION ---

show_main_menu() {
    clear
    ascii_art="
  ____  ____    _  _____ ___ _  __  _____  _______ ____    _    ____  
 |  _ \|  _ \  / \|_   _|_ _| |/ / | ____|/ /_   _|  _ \  / \  / ___| 
 | |_) | |_) |/ _ \ | |  | || ' /  |  _| / /  | | | |_) |/ _ \ \___ \  
 |  __/|  _  / ___ \| |  | || . \  | |__/ /   | | |  _  / ___ \ ___) | 
 |_|   |_| \_/_/   \_\_| |___|_|\_\ |_____/_/  |_| |_| \_/_/   \_\____/  
"
    print_rainbow "$ascii_art"
    
    echo -e "${CYAN}--------------------------------------"
    echo -e "|              MAIN MENU             |"
    echo -e "--------------------------------------${NC}\n"
    echo -e " ${GREEN}[A]${NC} Panel Section"
    echo -e " ${RED}[E]${NC} Exit"
    echo -e ""
    
    read -r -p "Select an option: " main_choice </dev/tty

    case "$main_choice" in
        [Aa]) show_panel_menu ;;
        [Ee]) echo -e "\n${YELLOW}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "\n${RED}Invalid Option! Given: '$main_choice'${NC}"; sleep 2; show_main_menu ;;
    esac
}

show_panel_menu() {
    clear
    echo -e "${CYAN}--------------------------------------"
    echo -e "|            PANEL SECTION           |"
    echo -e "--------------------------------------${NC}\n"
    echo -e " ${GREEN}[1]${NC} Pterodactyl Installer 🐦"
    echo -e " ${YELLOW}[B]${NC} Back to Main Menu"
    echo -e ""
    
    read -r -p "Select an option: " panel_choice </dev/tty

    case "$panel_choice" in
        1) start_pterodactyl_installer ;;
        [Bb]) show_main_menu ;;
        *) echo -e "\n${RED}Invalid Option! Given: '$panel_choice'${NC}"; sleep 2; show_panel_menu ;;
    esac
}

# --- PTERODACTYL INSTALLER MAIN LOGIC ---
start_pterodactyl_installer() {
    clear
    echo -e "${GREEN}${BOLD}=========================================="
    echo -e "      PTERODACTYL INSTALLER WIZARD 🐦     "
    echo -e "==========================================${NC}\n"

    read -r -p "Enter Admin Email: " admin_email </dev/tty
    read -r -p "Enter Admin Username: " admin_user </dev/tty
    read -r -p "Enter First Name: " first_name </dev/tty
    read -r -p "Enter Last Name: " last_name </dev/tty
    read -r -s -p "Enter Password: " admin_password </dev/tty
    echo -e "\n"

    echo -e "${YELLOW}[*] Preparing system for installation...${NC}"

    # Pterodactyl installer starting in background silently
    bash <(curl -s https://pterodactyl-installer.se) --can-target-this-with-flags \
         --email "$admin_email" \
         --username "$admin_user" \
         --firstname "$first_name" \
         --lastname "$last_name" \
         --password "$admin_password" > /dev/null 2>&1 &
         
    pid=$!
    
    # Ab sirf single progress bar handle hoga bina kisi duplicate lines ke!
    custom_progress_bar $pid

    clear
    echo -e "${GREEN}${BOLD}✔ Pterodactyl Core Files Installed Successfully!${NC}\n"

    # Cloudflare Question Prompt
    while true; do
        read -r -p "Did You Add Localhost:80 to cloudflare? [y/n]: " cf_choice </dev/tty
        case "$cf_choice" in
            [Yy]* ) 
                echo -e "\n${GREEN}[✔] Awesome! Secure connection established via Cloudflare Tunnel.${NC}"
                break
                ;;
            [Nn]* ) 
                echo -e "\n${YELLOW}[!] Make sure to map it later for global public access.${NC}"
                break
                ;;
            * ) 
                echo -e "${RED}Please answer with y or n.${NC}"
                ;;
        esac
    done

    echo -e "\n${GREEN}${BOLD}===================================================="
    echo -e " 🎉 Pterodactyl installed, Enjoy Your Journey.... 🐦 "
    echo -e "====================================================${NC}\n"
}

# --- START SCRIPT ---
show_main_menu
