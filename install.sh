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
    echo "" # Baseline for cursor physics
    for ((i=0; i<=steps; i++)); do
        local percent=$(( i * 100 / steps ))
        local msg_index=$(( i / (steps / ${#messages[@]}) ))
        if [ $msg_index -ge ${#messages[@]} ]; then
            msg_index=$(( ${#messages[@]} - 1 ))
        fi
        
        # Upper text update karne ke liye
        printf "\033[A\r\033[K${CYAN}${BOLD}%s${NC}\n" "${messages[$msg_index]}"
        
        # Progress Bar drawing
        printf "\r["
        for ((j=0; j<i; j++)); do printf "■"; done
        for ((j=i; j<steps; j++)); do printf " "; done
        printf "] %d%%" "$percent"
        
        sleep 0.04
    done
    echo -e "\n"
}

# Rainbow Text Function (Bold + Multi-color character by character)
print_rainbow() {
    local text="$1"
    # ANSI escape codes for bold rainbow colors
    local colors=(
        "\033[1;31m" # Red
        "\033[1;33m" # Yellow
        "\033[1;32m" # Green
        "\033[1;36m" # Cyan
        "\033[1;34m" # Blue
        "\033[1;35m" # Magenta
    )
    local color_count=${#colors[@]}
    local color_index=0

    # Read text line by line
    while IFS= read -r line; do
        # Process character by character
        for (( i=0; i<${#line}; i++ )); do
            local char="${line:$i:1}"
            # Spaces ko color nahi karte, direct print karte hain
            if [ "$char" == " " ]; then
                printf " "
            else
                printf "${colors[$color_index]}%s" "$char"
                color_index=$(( (color_index + 1) % color_count ))
            fi
        done
        printf "\n"
    done <<< "$text"
    printf "\033[0m" # Reset colors at the end
}

# --- SCRIPT EXECUTION STARTS HERE ---

# Progress bar run karein
progress_bar

# Screen clear for the grand finale
clear

# Fixed ASCII Art for PRATIK EXTRAS
ascii_art="
  ____  ____    _  _____ ___ _  __  _____  _______ ____    _    ____  
 |  _ \|  _ \  / \|_   _|_ _| |/ / | ____|/ /_   _|  _ \  / \  / ___| 
 | |_) | |_) |/ _ \ | |  | || ' /  |  _| / /  | | | |_) |/ _ \ \___ \  
 |  __/|  _  / ___ \| |  | || . \  | |__/ /   | | |  _  / ___ \ ___) | 
 |_|   |_| \_/_/   \_\_| |___|_|\_\ |_____/_/  |_| |_| \_/_/   \_\____/  
"

# Printing with bold rainbow effect
print_rainbow "$ascii_art"

echo -e "\n${CYAN}${BOLD}Installation completed successfully! Welcome to Pratik Extras.${NC}\n"
