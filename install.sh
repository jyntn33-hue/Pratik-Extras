#!/bin/bash

# Screen clear karne ke liye
clear

# Text formatting ke liye colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Loading messages ki array
messages=("Initializing..." "Checking System..." "Fetching Resources..." "Making It Happen..." "Finishing Up...")

# Progress Bar Function
progress_bar() {
    local duration=$1
    local steps=50 # Bar ki width
    
    for ((i=0; i<=steps; i++)); do
        # Percentage calculate karne ke liye
        local percent=$(( i * 100 / steps ))
        
        # Message index change karne ke liye based on progress
        local msg_index=$(( i / (steps / ${#messages[@]}) ))
        if [ $msg_index -ge ${#messages[@]} ]; then
            msg_index=$(( ${#messages[@]} - 1 ))
        fi
        
        # Upper text update karne ke liye (\033[A se cursor upar jata hai aur line clear hoti hai)
        printf "\033[A\r\033[K${CYAN}${BOLD}%s${NC}\n" "${messages[$msg_index]}"
        
        # Custom Progress Bar drawing
        printf "\r["
        for ((j=0; j<i; j++)); do printf "■"; done
        for ((j=i; j<steps; j++)); do printf " "; done
        printf "] %d%%" "$percent"
        
        # Delay simulate karne ke liye
        sleep 0.05
    done
    echo -e "\n"
}

# Pehle blank line taaki upper text crash na ho
echo ""
# Progress bar run karein (0.05 sleep ke sath ye ~2.5 seconds lega)
progress_bar

# Final ASCII Art Output
clear
echo -e "${GREEN}${BOLD}"
cat << "EOF"
  ____                 _   _ _        _____ ___ _        _     
 |  _ \ _ __  __ _    | | (_) | __   | ____|_ _| |_ _ __ __ _ ___ 
 | |_) | '__|/ _` |   | | | | |/ /   |  _|  | || __| '__/ _` / __|
 |  __/| |  | (_| |   | | | |   <    | |___ | || |_| | | (_| \__ \
 |_|   |_|   \__,_|___|_| |_|_|\_\___|_____|___|\__|_|  \__,_|___/
                 |_____|         |_____|                          
EOF
echo -e "${NC}"

echo -e "${CYAN}Installation completed successfully! Welcome to Pratik Extras.${NC}\n"
