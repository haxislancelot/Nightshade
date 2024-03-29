#!/system/bin/sh
clear

# Check if the user is not root
if [ "$(whoami)" != "root" ]; then
    su -c chmod +x /data/data/com.termux/files/home/start.sh
    su -c /data/data/com.termux/files/home/start.sh
    exit
fi

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "Please install curl before using this script."
    exit 1
fi

# Function to ask the user if he wants to update the main script
ask_update_script() {
	clear
    while true; do
        echo "Do you want to update the main script? (yes/no)"
        echo -n "> "
        read answer
        case $answer in
            [Yy]* )
                echo "Downloading the main script..."
                curl -o "/sdcard/.tweaks.sh" "https://raw.githubusercontent.com/haxislancelot/Nightshade/main/main/tweaks.sh"
                break;;
            [Nn]* )
                echo "Not updating the main script."
                break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Colors
F='\033[0m'
G='\033[0;32m'
R='\033[0;31m'
N='\033[0;90m'

# Device information
version=$(echo "v2.0.1-Beta")
author=$(echo "haxislancelot @ Github")
uptime=$(uptime)
kernel=$(uname -r)
android_sdk=$(getprop ro.build.version.sdk)
build_desc=$(getprop ro.build.description)
product=$(getprop ro.build.product)
manufacturer=$(getprop ro.product.manufacturer)
brand=$(getprop ro.product.brand)
model=$(getprop ro.product.model)
fingerprint=$(getprop ro.build.fingerprint)
arch=$(getprop ro.product.cpu.abi)
device=$(getprop ro.product.device)
android=$(getprop ro.build.version.release)
build=$(getprop ro.build.id)

# Animation
animate_colors() {
    text="$1"
    colors=("41" "46" "43" "44" "45" "42")
    color_count=${#colors[@]}

    i=0
    while [ $i -lt $color_count ]; do
        current_color=${colors[i]}
        echo -ne "\e[1;${current_color}m$text\e[0m\r"
        sleep 0.5
        i=$((i + 1))
    done
}

animate_typing() {
    text="$1"
    color="$2"
    i=0
    while [ $i -lt ${#text} ]; do
        echo -en "\e[${color}m${text:$i:1}\e[0m"
        sleep 0.01
        i=$((i + 1))
    done
    echo
}

animate_colors "Welcome to Nightshade CLI!" && echo ""
sleep 0.1
main_menu() {
	clear
	echo "███╗   ██╗████████╗███████╗██╗  ██╗"
    sleep 0.1
	echo "████╗  ██║╚══██╔══╝██╔════╝██║  ██║"
    sleep 0.1
    echo "██╔██╗ ██║   ██║   ███████╗███████║"
    sleep 0.1
    echo "██║╚██╗██║   ██║   ╚════██║██╔══██║"
    sleep 0.1
    echo "██║ ╚████║   ██║   ███████║██║  ██║"
    sleep 0.1
    echo "╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝"
    echo ""
    animate_typing "Time: `date`" "32"
    animate_typing "Version: ${version}" "32"
    animate_typing "Author: ${author}" "32"
    animate_typing "Your Device Information:" "32"
    echo ""
    animate_typing "[ - ] Manufacturer: ${manufacturer}" "90"
    animate_typing "[ - ] Brand: ${brand}" "90"
    animate_typing "[ - ] Device: ${device}" "90"
    animate_typing "[ - ] Product: ${product}" "90"
    animate_typing "[ - ] Model: ${model}" "90"
    animate_typing "[ - ] Architecture: ${arch}" "90"
    animate_typing "[ - ] Android build: ${build}" "90"
    animate_typing "[ - ] Android version: ${android}" "90"
    animate_typing "[ - ] Android sdk: ${android_sdk}" "90"
    animate_typing "[ - ] Kernel Version: ${kernel}" "90"
    echo ""
    sleep 0.1
    animate_typing "[ - ] Modes [ 1 ]" "90"
    sleep 0.1
    animate_typing "[ - ] Plugins [ 2 ]" "90"
    sleep 0.1
    animate_typing "[ - ] Support [ 3 ]" "90"
    sleep 0.1
    animate_typing "[ - ] Update [ 4 ]" "90"
    sleep 0.1
    echo ""
    sleep 0.1
    echo -ne "${G}Enter your choice: ${F}"
    read choice
    
    case $choice in
        1) 
            mode
            ;;
        2)    
            plugins
            ;;
        3)
            ;;
        4)
            ask_update_script
            main_menu
            ;;
        *)
            echo -e "\e[41mInvalid choice!\e[0m"
            sleep 1
            main_menu
            ;;
    esac            
}
    
mode() {
    clear
    animate_typing "Performance [ 1 ]" "90"
    sleep 0.1
    animate_typing "Battery [ 2 ]" "90"
    sleep 0.1
    animate_typing "Balanced [ 3 ]" "90"
    sleep 0.1
    animate_typing "Thermal [ 4 ]" "90"
    sleep 0.1
    animate_typing "Gaming [ 5 ]" "90"
    sleep 0.1
    animate_typing "Return to main menu [ 6 ]" "90"
    sleep 0.1
    echo ""
    sleep 0.1
    echo -ne "${G}Enter your choice: ${F}"
    read choice

    case $choice in
        1)
            setprop persist.nightshade.mode 4
            sh /sdcard/.tweaks.sh > /dev/null
            echo "1" > /data/local/tmp/last_mode
            mode
            ;;
        2)
            setprop persist.nightshade.mode 2
            sh /sdcard/.tweaks.sh > /dev/null
            echo "2" > /data/local/tmp/last_mode
            mode
            ;;
        3)
            setprop persist.nightshade.mode 3
            sh /sdcard/.tweaks.sh > /dev/null
            echo "3" > /data/local/tmp/last_mode
            mode
            ;;
        4)
            setprop persist.nightshade.mode 6
            sh /sdcard/.tweaks.sh > /dev/null
            echo "4" > /data/local/tmp/last_mode
            mode
            ;;
        5)
            setprop persist.nightshade.mode 5
            sh /sdcard/.tweaks.sh > /dev/null
            echo "5" > /data/local/tmp/last_mode
            mode
            ;;
        6)
            main_menu
            ;;
        *)
            echo -e "\e[41mInvalid choice!\e[0m"
            sleep 1
            mode
            ;;
    esac
}

# List the scripts in the /sdcard/.NTSH/plugins folder and enumerate them
list_plugins() {
    local counter=1
    for plugin in /sdcard/.NTSH/plugins/*.sh; do
        if [ -f "$plugin" ]; then
            plugin_name=$(basename "$plugin" .sh)
            echo "$plugin_name [ $counter ]"
            ((counter++))
            sleep 0.1  # Adds a 0.1 second interval between each plugin
        fi
    done
}

# Function to run a plugin based on the number provided by the user
execute_plugin() {
    local plugin_number=$1
    local plugin_path="/sdcard/.NTSH/plugins/$plugin_number.sh"

    if [ -f "$plugin_path" ]; then
        chmod +x "$plugin_path"
        . "$plugin_path"
    else
        echo -e "\e[41mInvalid plugin!\e[0m"
        sleep 1
        plugins
    fi
}

plugins() {
	clear
	animate_typing "Type x to return" "90"
	sleep 0.1
	echo ""
    list_plugins
    echo "${F}"
    sleep 0.1
    
    while true; do
        echo -ne "${G}Enter your choice: ${F}"
        read selected_plugin_number

        if [ "$selected_plugin_number" == "x" ]; then
            main_menu
            break
        elif [ "$selected_plugin_number" == "plugins" ]; then
            list_plugins
        else
            selected_plugin_name=$(list_plugins | grep "\[ $selected_plugin_number \]" | cut -d "[" -f 1 | tr -d '[:space:]')
            execute_plugin "$selected_plugin_name"
            break
        fi
    done
}

main_menu