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

# Check if the directory /sdcard/.NTSH exists
if [ ! -d "/sdcard/.NTSH" ]; then
    # If it doesn't exist, create the directory
    mkdir -p "/sdcard/.NTSH"
else
    # If it exists, do nothing
    :
fi

# Check if the directory /sdcard/.NTSH/plugins exists
if [ ! -d "/sdcard/.NTSH/plugins" ]; then
    # If it doesn't exist, create the directory
    mkdir -p "/sdcard/.NTSH/plugins"
else
    # If it exists, do nothing
    :
fi

# Checks if the main script exists, if not download the main script and plugins
if [ ! -d "/sdcard/.tweaks.sh" ]; then
    # If it doesn't exist, create the file
    curl -o "/sdcard/.tweaks.sh" "https://raw.githubusercontent.com/haxislancelot/Nightshade/main/main/tweaks.sh" && curl -o /sdcard/plugins_list.sh "https://raw.githubusercontent.com/haxislancelot/Nightshade/main/plugins/plugins_list" && sh /sdcard/plugins_list.sh && rm -rf /sdcard/plugins_list.sh
    clear
else
    # If it exists, do nothing
    :
fi

# Function to ask the user if he wants to update the main script
ask_update_script() {
	clear
    while true; do
        echo "\033[0;90mDo you want to update the main script and plugins? (yes/no)"
        echo -n "> ${F}"
        read answer
        case $answer in
            [Yy]* )
                echo "\033[0;90mDownloading...${F}"
                curl -o "/sdcard/.tweaks.sh" "https://raw.githubusercontent.com/haxislancelot/Nightshade/main/main/tweaks.sh" && curl -o /sdcard/plugins_list.sh "https://raw.githubusercontent.com/haxislancelot/Nightshade/main/plugins/plugins_list" && sh /sdcard/plugins_list.sh && rm -rf /sdcard/plugins_list.sh && echo "${G}Main script and plugins updated successfully!${F}"
                echo -n "\033[0;90mClick to continue...${F}"
                read &&
                sh start.sh
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

main_menu() {
	clear
	echo "███╗   ██╗████████╗███████╗██╗  ██╗"
	sleep 0
	echo "████╗  ██║╚══██╔══╝██╔════╝██║  ██║"
	sleep 0
    echo "██╔██╗ ██║   ██║   ███████╗███████║"
    sleep 0
    echo "██║╚██╗██║   ██║   ╚════██║██╔══██║"
    sleep 0
    echo "██║ ╚████║   ██║   ███████║██║  ██║"
    sleep 0
    echo "╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝"
    echo ""
    sleep 0
    echo "${G}Time: `date`"
    sleep 0
    echo "Version: ${version}"
    sleep 0
    echo "Author: ${author}"
    sleep 0
    echo "Your Device Information:${F}"
    echo ""
    sleep 0
    echo "\033[0;90m[ - ] Manufacturer: ${manufacturer}"
    sleep 0
    echo "[ - ] Brand: ${brand}"
    sleep 0
    echo "[ - ] Device: ${device}"
    sleep 0
    echo "[ - ] Product: ${product}"
    sleep 0
    echo "[ - ] Model: ${model}"
    sleep 0
    echo "[ - ] Architecture: ${arch}"
    sleep 0
    echo "[ - ] Android build: ${build}"
    sleep 0
    echo "[ - ] Android version: ${android}"
    sleep 0
    echo "[ - ] Android sdk: ${android_sdk}"
    sleep 0
    echo "[ - ] Kernel Version: ${kernel}"
    echo ""
    sleep 0
    echo "[ - ] Modes [ 1 ]"
    sleep 0
    echo "[ - ] Plugins [ 2 ]"
    sleep 0
    echo "[ - ] Support [ 3 ]"
    sleep 0
    echo "[ - ] Update [ 4 ]"
    sleep 0
    echo "[ - ] Exit [ 0 ]"
    echo ""
    sleep 0
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
            am start -a android.intent.action.VIEW -d https://t.me/nihilprojects > /dev/null
            main_menu
            ;;
        4)
            ask_update_script
            main_menu
            ;;
        0)
            exit
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
    sleep 0
    echo "\033[0;90m[ - ] Performance [ 1 ]"
    sleep 0
    echo "[ - ] Battery [ 2 ]"
    sleep 0
    echo "[ - ] Balanced [ 3 ]"
    sleep 0
    echo "[ - ] Thermal [ 4 ]"
    sleep 0
    echo "[ - ] Gaming [ 5 ]"
    sleep 0
    echo "[ - ] Return to main menu [ 6 ]"
    echo ""
    sleep 0
    echo -ne "${G}Enter your choice: ${F}"
    read choice

    case $choice in
        1)
            setprop persist.nightshade.mode 4
            sh /sdcard/.tweaks.sh > /dev/null 2>&1
            mode
            ;;
        2)
            setprop persist.nightshade.mode 2
            sh /sdcard/.tweaks.sh > /dev/null 2>&1
            mode
            ;;
        3)
            setprop persist.nightshade.mode 3
            sh /sdcard/.tweaks.sh > /dev/null 2>&1
            mode
            ;;
        4)
            setprop persist.nightshade.mode 6
            sh /sdcard/.tweaks.sh > /dev/null 2>&1
            mode
            ;;
        5)
            setprop persist.nightshade.mode 5
            sh /sdcard/.tweaks.sh > /dev/null 2>&1
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
            sleep 0
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
	sleep 0
	echo "${G}Type x to return to main menu\033[0;90m"
	echo ""
	sleep 0
    list_plugins
    echo "${F}"
    
    while true; do
        sleep 0
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
