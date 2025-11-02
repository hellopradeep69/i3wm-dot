#!/usr/bin/env bash

# === Color codes ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
RESET='\033[0m' # Reset color

Start_menu() {
    clear
    echo -e "${BLUE}"
    echo "     ┓       "
    echo "┓┏┏┏┓┃┏┏┓┏┳┓┏┓  ╋┏┓"
    echo "┗┻┛┗ ┗┗┗┛┛┗┗┗   ┗┗┛"
    echo -e "${YELLOW}"
    echo "▓█████▄  ▒█████  ▄▄▄█████▓ ▄████▄   ▒█████   ███▄    █   █████▒"
    echo "▒██▀ ██▌▒██▒  ██▒▓  ██▒ ▓▒▒██▀ ▀█  ▒██▒  ██▒ ██ ▀█   █ ▓██   ▒ "
    echo "░██   █▌▒██░  ██▒▒ ▓██░ ▒░▒▓█    ▄ ▒██░  ██▒▓██  ▀█ ██▒▒████ ░ "
    echo "░▓█▄   ▌▒██   ██░░ ▓██▓ ░ ▒▓▓▄ ▄██▒▒██   ██░▓██▒  ▐▌██▒░▓█▒  ░ "
    echo "░▒████▓ ░ ████▓▒░  ▒██▒ ░ ▒ ▓███▀ ░░ ████▓▒░▒██░   ▓██░░▒█░    "
    echo "▒▒▓  ▒ ░ ▒░▒░▒░   ▒ ░░   ░ ░▒ ▒  ░░ ▒░▒░▒░ ░ ▒░   ▒ ▒  ▒ ░    "
    echo "░ ▒  ▒   ░ ▒ ▒░     ░      ░  ▒     ░ ▒ ▒░ ░ ░░   ░ ▒░ ░      "
    echo "░ ░  ░ ░ ░ ░ ▒    ░      ░        ░ ░ ░ ▒     ░   ░ ░  ░ ░    "
    echo "░        ░ ░           ░ ░          ░ ░           ░         "
    echo "░                        ░                                    "
    echo -e "${RESET}"

    echo ""
    echo -e "${CYAN} Greeting's ${GREEN}$(whoami)${RESET}"
    echo ""
    echo -e "${YELLOW} Disclaimer:${RESET}"
    echo "  This setup script will:"
    echo "   • Install required packages and tools."
    echo "   • Copy your Qtile and related configuration files."
    echo "   • Automatically back up any existing configuration files"
    echo "     before replacing them with new ones."
    echo ""
    echo "  Backups are stored in:"
    echo "     ~/config_backups_<timestamp>/"
    echo ""
    echo "  Use this script at your own discretion. It may overwrite existing configurations."
    echo -e "${RED} ---------------------------------------------------------${RESET}"
    echo ""

    read -p "Do you want to continue (Y/n): " Value
    if [[ "$Value" = "y" || "$Value" = "Y" ]]; then
        echo -e "${GREEN}Running the script...${RESET}"
        sleep 1
        echo -ne "${CYAN}Loading"
        for i in {1..5}; do
            echo -ne "."
            sleep 0.5
        done
        echo -e "${RESET}"
    else
        echo -e "${YELLOW}Doesn’t matter... continuing anyway ${RESET}"
        sleep 2
        echo -ne "${CYAN}Loading"
        for i in {1..5}; do
            echo -ne "."
            sleep 0.5
        done
        echo ""
        echo -e "${RED}Just kidding!${RESET}"
        echo -e "${RED}Aborting.${RESET}"
        exit 0
    fi
}

Start_menu
echo ""
echo -e "${GREEN}Running...${RESET}"

# #!/usr/bin/env bash
#
# RED='\033[0;31m'
# GREEN='\033[0;32m'
# YELLOW='\033[1;33m'
# BLUE='\033[0;34m'
#
# Start_menu() {
#
#     clear
#     echo "     ┓       "
#     echo "┓┏┏┏┓┃┏┏┓┏┳┓┏┓  ╋┏┓"
#     echo "┗┻┛┗ ┗┗┗┛┛┗┗┗   ┗┗┛"
#     echo "▓█████▄  ▒█████  ▄▄▄█████▓ ▄████▄   ▒█████   ███▄    █   █████▒"
#     echo "▒██▀ ██▌▒██▒  ██▒▓  ██▒ ▓▒▒██▀ ▀█  ▒██▒  ██▒ ██ ▀█   █ ▓██   ▒ "
#     echo "░██   █▌▒██░  ██▒▒ ▓██░ ▒░▒▓█    ▄ ▒██░  ██▒▓██  ▀█ ██▒▒████ ░ "
#     echo "░▓█▄   ▌▒██   ██░░ ▓██▓ ░ ▒▓▓▄ ▄██▒▒██   ██░▓██▒  ▐▌██▒░▓█▒  ░ "
#     echo "░▒████▓ ░ ████▓▒░  ▒██▒ ░ ▒ ▓███▀ ░░ ████▓▒░▒██░   ▓██░░▒█░    "
#     echo "▒▒▓  ▒ ░ ▒░▒░▒░   ▒ ░░   ░ ░▒ ▒  ░░ ▒░▒░▒░ ░ ▒░   ▒ ▒  ▒ ░    "
#     echo "░ ▒  ▒   ░ ▒ ▒░     ░      ░  ▒     ░ ▒ ▒░ ░ ░░   ░ ▒░ ░      "
#     echo "░ ░  ░ ░ ░ ░ ▒    ░      ░        ░ ░ ░ ▒     ░   ░ ░  ░ ░    "
#     echo "░        ░ ░           ░ ░          ░ ░           ░         "
#     echo "░                        ░                                    "
#     echo ""
#     echo " Greeting's $(whoami)"
#     echo ""
#     echo " Disclamier :"
#     echo "  This setup script will:"
#     echo "   • Install required packages and tools."
#     echo "   • Copy your Qtile and related configuration files."
#     echo "   • Automatically back up any existing configuration files"
#     echo "     before replacing them with new ones."
#     echo ""
#     echo " Backups are stored in:"
#     echo "     ~/config_backups_<timestamp>/"
#     echo ""
#     echo " Use this script at your own discretion. It is designed for"
#     echo " personal setups and may overwrite existing configurations."
#     echo " ---------------------------------------------------------"
#     read -p " do you want to continue(Y/n): " Value
#     if [[ "$Value" = "y" || "$Value" = "Y" ]]; then
#         echo " running the script"
#         sleep 3
#         echo -ne " Loading"
#         for i in {1..5}; do
#             echo -ne "."
#             sleep 1
#         done
#     else
#         sleep 4
#         echo " "
#         echo " doesnt matter .. Continuing"
#         sleep 3
#         echo -ne " Loading"
#         for i in {1..5}; do
#             echo -ne "."
#             sleep 1
#         done
#         echo " "
#         echo " just kidding !"
#         echo " Abort "
#         exit 0
#     fi
#
# }
#
# Start_menu
#
# echo " "
# echo " running"
