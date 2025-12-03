#!/bin/bash

# ==============================================================
# CYBER-STYLE COLORS - CODED BY cmd@hacker
# ==============================================================
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
CYAN="\e[36m"
YELLOW="\e[33m"
MAGENTA="\e[35m"
RESET="\e[0m"
BOLD="\e[1m"

# ==============================================================
# CYBER BANNER FUNCTION - CODED BY cmd@hacker
# ==============================================================
banner() {
clear
echo -e "${GREEN}==============================================================================${RESET}"
echo -e "${CYAN} █        █ ██   ██   ██████                    █        █ ██   ██   ██████    ${RESET}"
echo -e "${CYAN}  █      █  █ █   █  ██        █                 █      █  █ █   █  ██         ${RESET}"
echo -e "${CYAN}   █    █   █  █  █  ██       ███  ████ ████      █    █   █  █  █  ██         ${RESET}"
echo -e "${CYAN}    █  █    █   █ █  ██        █   █  █ █  █       █  █    █   █ █  ██         ${RESET}"
echo -e "${CYAN}     ██     ██   ██   ██████       █  █ ████        ██     ██   ██   ██████    ${RESET}"
echo -e "${GREEN}==============================================================================${RESET}"
echo -e "${YELLOW}           TANZANIA CYBERSECURITY ACADEMY (TCA)             ${RESET}"
echo -e "${YELLOW}      www.tca.ac.tz | Professional Cybersecurity Training   ${RESET}"
echo -e "${RED}              secure the digital future today!   ${RESET}"
echo -e "${GREEN}==============================================================================${RESET}"
echo ""
}

# ==============================================================
# CHECK IF INSTALLED FUNCTION - CODED BY cmd@hacker
# ==============================================================
is_installed() {
    command -v x11vnc >/dev/null 2>&1 && \
    command -v websockify >/dev/null 2>&1 && \
    ls /usr/share/novnc >/dev/null 2>&1
}

# ==============================================================
# INSTALL FUNCTION - CODED BY cmd@hacker
# ==============================================================
install_tools() {
    banner
    if is_installed; then
        echo -e "${GREEN}✔ x11vnc + noVNC are already installed.${RESET}"
        echo -e "Press Enter to return to menu..."
        read
        return
    fi

    echo -e "${CYAN}Installing x11vnc, noVNC and websockify...${RESET}"
    sudo apt update
    sudo apt install -y x11vnc novnc websockify
    echo -e "${GREEN}Installation complete!${RESET}"
    echo "Press Enter to return to menu..."
    read
}

# ==============================================================
# START FUNCTION - CODED BY cmd@hacker
# ==============================================================
start_vnc() {
    banner
    if ! is_installed; then
        echo -e "${RED}❌ Error: x11vnc + noVNC are NOT installed.${RESET}"
        echo "Press Enter to return to menu... and select option 1"
        read
        return
    fi

echo -e "${CYAN}=================================================${RESET}"
echo -e "${MAGENTA}      Welcome! Start x11vnc + noVNC              ${RESET}"
echo -e "${MAGENTA}      Coded by: Tanzania Cybersecurity Academy  ${RESET}"
echo -e "${CYAN}=================================================${RESET}"

# Detect available X displays
DISPLAYS=$(ls /tmp/.X11-unix | sed 's/X//')
if [ -z "$DISPLAYS" ]; then
    echo -e "${RED}No X displays found!${RESET}"
    exit 1
fi

echo "Available X displays:"
select DISP in $DISPLAYS; do
    if [ -n "$DISP" ]; then
        echo "You selected display :$DISP"
        break
    else
        echo "Invalid selection, try again."
    fi
done

# Ask for TCP port with default
read -p "Enter VNC TCP port (default 5901): " VNCPORT
VNCPORT=${VNCPORT:-5901}

# Ask if user wants to set a password
read -p "Do you want to set a VNC password? (y/n): " SETPASS
if [[ "$SETPASS" =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}Setting VNC password...${RESET}"
    x11vnc -storepasswd ~/.vnc_pass
    PASSOPT="-rfbauth ~/.vnc_pass"
else
    PASSOPT="-nopw"
fi

# Ask noVNC port
read -p "Enter noVNC web port (default 6080): " NOVNCPORT
NOVNCPORT=${NOVNCPORT:-6080}

echo ""
echo -e "${CYAN}Starting x11vnc on display $DISP ...${RESET}"
x11vnc $PASSOPT -display $DISP -forever -shared -noxdamage -bg -rfbport $VNCPORT

echo -e "${CYAN}Starting noVNC on http://localhost:$NOVNCPORT ...${RESET}"
websockify --web=/usr/share/novnc $NOVNCPORT localhost:$VNCPORT &

echo ""
echo -e "${GREEN}=================================================${RESET}"
echo -e "${YELLOW} noVNC running at: http://localhost:$NOVNCPORT${RESET}/vnc.html"
echo -e "${YELLOW} access remote at: http://{machine ip addr}:$NOVNCPORT${RESET}/vnc.html"
echo -e "${YELLOW} VNC port: $VNCPORT | Display: $DISP${RESET}"
echo -e "${GREEN}=================================================${RESET}"
echo "Press Enter to return to menu..."
read
}

# ==============================================================
# UNINSTALL FUNCTION - CODED BY cmd@hacker
# ==============================================================
uninstall_tools() {
    banner
    if ! is_installed; then
        echo -e "${GREEN}✔ x11vnc + noVNC are NOT installed.${RESET}"
        echo "Press Enter to return to menu..."
        read
        return
    fi

    echo -e "${RED}Uninstalling x11vnc, noVNC and websockify...${RESET}"
    sudo apt remove --purge -y x11vnc novnc websockify
    sudo apt autoremove -y

    echo "Cleaning leftover password file..."
    rm -f ~/.vnc_pass
    echo -e "${GREEN}Uninstallation complete.${RESET}"
    echo "Press Enter to return to menu..."
    read
}

# ==============================================================
# MAIN LOOP MENU - CODED BY cmd@hacker
# ==============================================================
while true; do
    banner
    echo -e "${CYAN}Choose an option:${RESET}"
    echo -e "${YELLOW}1) Install x11vnc + noVNC${RESET}"
    echo -e "${YELLOW}2) Start installed x11vnc + noVNC${RESET}"
    echo -e "${YELLOW}3) Uninstall x11vnc + noVNC${RESET}"
    echo -e "${YELLOW}4) Exit${RESET}"
    echo ""
    read -p "Enter your choice (1-4): " CHOICE

    case $CHOICE in
        1) install_tools ;;
        2) start_vnc ;;
        3) uninstall_tools ;;
        4) echo -e "${GREEN}Goodbye!${RESET}"; exit 0 ;;
        *) echo -e "${RED}Invalid option! Try again.${RESET}"; sleep 1 ;;
    esac
done
