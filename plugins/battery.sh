#!/bin/bash
# This is experimental and may be buggy.

# Colors
G='\e[01;32m'      # GREEN TEXT
R='\e[01;31m'      # RED TEXT
Y='\e[01;33m'      # YELLOW TEXT
B='\e[01;34m'      # BLUE TEXT
V='\e[01;35m'      # VIOLET TEXT
Bl='\e[01;30m'     # BLACK TEXT
C='\e[01;36m'      # CYAN TEXT
W='\e[01;37m'      # WHITE TEXT
BGBL='\e[1;104m'   # Background Light Blue
N='\e[0m'          # Reset color codes

# Function to display battery information
displayBatteryInfo() {
  voltageMax=$(cat /sys/class/power_supply/battery/voltage_max)
  temperature=$(($(cat /sys/class/power_supply/battery/temp) / 10)) # Divide por dez
  echo -e "${W}Battery Panel${N}"
  echo -e "${G}Voltage Max:${N} ${B}${voltageMax} mV${N}"
  echo -e "${G}Temperature:${N} ${Y}${temperature} °C${N}"
}

# Function to display a dynamic loading bar
loadingBar() {
  echo -n "Loading: ["
  i=1
  while [ $i -le 20 ]; do
    percentage=$((i * 5))
    echo -ne "$percentage%"
    if [ $i -lt 20 ]; then
      echo -n "|"
    else
      echo -n "]"
    fi
    sleep 1
    ((i++))
  done
  echo -ne "                \r"  # Clear the loading bar
}


# Main script
clear

echo -e "${BGBL}${W} Battery Panel ${N}"

while true; do
  # Display battery information
  displayBatteryInfo

  # Display dynamic loading bar
  loadingBar

  # Clear the screen for the next iteration
  clear
done
