#!/bin/bash

# ==============================================================
# CYBER-STYLE COLORS - CODED BY cmd@hacker - www.tca.ac.tz
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
# CYBER BANNER FUNCTION - CODED BY cmd@hacker - www.tca.ac.tz
# ==============================================================
banner() {
clear
echo ""
echo ""
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
# CHECK INSTALLATION - CODED BY cmd@hacker - www.tca.ac.tz
# ==============================================================
is_installed() {
    command -v x11vnc >/dev/null 2>&1 &&
    command -v websockify >/dev/null 2>&1 &&
    [ -d /usr/share/novnc ]
}

# ==============================================================
# INSTALL TOOLS - CODED BY cmd@hacker - www.tca.ac.tz
# ==============================================================
install_tools() {
    banner

    if is_installed; then
        echo -e "${GREEN}✔ Already installed${RESET}"
        read -p "Press Enter..."
        return
    fi

    echo -e "${CYAN}Installing x11vnc + noVNC...${RESET}"
    sudo apt update
    sudo apt install -y x11vnc novnc websockify

    echo -e "${GREEN}Installation complete${RESET}"
    read -p "Press Enter..."
}

# ==============================================================
# STOP SERVICES - CODED BY cmd@hacker - www.tca.ac.tz
# ==============================================================
stop_vnc() {
    banner
    echo -e "${CYAN}Stopping services...${RESET}"

    pkill -f x11vnc 2>/dev/null
    pkill -f websockify 2>/dev/null

    echo -e "${GREEN}Stopped.${RESET}"
    read -p "Press Enter..."
}

# ==============================================================
# STATUS CHECK - CODED BY cmd@hacker - www.tca.ac.tz
# ==============================================================
status_vnc() {
    banner
    echo -e "${CYAN}Service Status${RESET}"
    echo ""

    if pgrep -f x11vnc >/dev/null; then
        echo -e "${GREEN}x11vnc running${RESET}"
    else
        echo -e "${RED}x11vnc not running${RESET}"
    fi

    if pgrep -f websockify >/dev/null; then
        echo -e "${GREEN}noVNC running${RESET}"
    else
        echo -e "${RED}noVNC not running${RESET}"
    fi

    echo ""
    ss -tulpn | grep -E '590|6080' || echo "No ports active"

    read -p "Press Enter..."
}

# ==============================================================
# START VNC SYSTEM - CODED BY cmd@hacker - www.tca.ac.tz
# ==============================================================
start_vnc() {
    banner

    if ! is_installed; then
        echo -e "${RED}Not installed${RESET}"
        read -p "Press Enter..."
        return
    fi

    echo -e "${CYAN}Detecting display...${RESET}"

    DISPLAYS=$(ls /tmp/.X11-unix 2>/dev/null | sed 's/^X//')

    if [ -z "$DISPLAYS" ]; then
        echo -e "${RED}No display found${RESET}"
        read -p "Press Enter..."
        return
    fi

    echo "Available displays:"
    select DISP in $DISPLAYS; do
        [ -n "$DISP" ] && break
    done

    DISPLAY_NAME=":$DISP"

    read -p "VNC port [5901]: " VNCPORT
    VNCPORT=${VNCPORT:-5901}

    read -p "noVNC port [6080]: " NOVNCPORT
    NOVNCPORT=${NOVNCPORT:-6080}

    echo ""
    echo "Mode:"
    echo "1) View Only"
    echo "2) Full Control"
    read -p "Choose [2]: " MODE
    MODE=${MODE:-2}

    if [ "$MODE" = "1" ]; then
        VIEWOPT="-viewonly"
        MODETEXT="View Only"
    else
        VIEWOPT=""
        MODETEXT="Full Control"
    fi

    read -p "Set VNC password? (y/n): " PASS
    if [[ "$PASS" =~ ^[Yy]$ ]]; then
        x11vnc -storepasswd ~/.vnc_pass
        PASSOPT="-rfbauth ~/.vnc_pass"
    else
        PASSOPT="-nopw"
    fi

    pkill -f x11vnc 2>/dev/null
    pkill -f websockify 2>/dev/null

    echo -e "${CYAN}Starting x11vnc...${RESET}"

    x11vnc $PASSOPT $VIEWOPT \
        -display "$DISPLAY_NAME" \
        -forever -shared -noxdamage -bg \
        -rfbport "$VNCPORT" \
        -o /tmp/x11vnc.log

    sleep 2

    if ! ss -ltn | grep -q ":$VNCPORT "; then
        echo -e "${RED}x11vnc failed${RESET}"
        tail -20 /tmp/x11vnc.log
        read -p "Press Enter..."
        return
    fi

    echo -e "${CYAN}Starting noVNC...${RESET}"

    websockify --web=/usr/share/novnc \
        "$NOVNCPORT" \
        localhost:"$VNCPORT" \
        >/tmp/novnc.log 2>&1 &

    sleep 2

    SERVER_IP=$(hostname -I | awk '{print $1}')

    echo ""
    echo -e "${GREEN}=========================================${RESET}"
    echo -e "${GREEN}SERVER STARTED${RESET}"
    echo -e "${GREEN}=========================================${RESET}"
    echo "Mode: $MODETEXT"
    echo "Display: $DISPLAY_NAME"
    echo "VNC: $VNCPORT"
    echo "Web: $NOVNCPORT"
    echo ""
    echo "Local: http://localhost:$NOVNCPORT/vnc.html"
    echo "Remote: http://$SERVER_IP:$NOVNCPORT/vnc.html"
    echo -e "${GREEN}=========================================${RESET}"

    read -p "Press Enter..."
}

# ==============================================================
# UNINSTALL - CODED BY cmd@hacker - www.tca.ac.tz
# ==============================================================
uninstall_tools() {
    banner

    echo -e "${RED}Removing packages...${RESET}"

    pkill -f x11vnc 2>/dev/null
    pkill -f websockify 2>/dev/null

    sudo apt remove --purge -y x11vnc novnc websockify
    sudo apt autoremove -y

    rm -f ~/.vnc_pass
    rm -f /tmp/x11vnc.log /tmp/novnc.log

    echo -e "${GREEN}Removed${RESET}"
    read -p "Press Enter..."
}

# ==============================================================
# MENU - CODED BY cmd@hacker - www.tca.ac.tz
# ==============================================================
while true; do
    banner

    echo -e "${CYAN}MENU TO CHOOSE${RESET}"
    echo "1) Install"
    echo "2) Start VNC"
    echo "3) Stop VNC"
    echo "4) Status"
    echo "5) Uninstall"
    echo "6) Exit"
    echo ""

    read -p "Choose: " CHOICE

    case $CHOICE in
        1) install_tools ;;
        2) start_vnc ;;
        3) stop_vnc ;;
        4) status_vnc ;;
        5) uninstall_tools ;;
        6) exit 0 ;;
        *) echo "Invalid"; sleep 1 ;;
    esac
done
