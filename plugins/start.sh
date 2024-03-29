#!/system/bin/sh
clear

# Function to animate text with automatically changing colors
animate() {
    local text="$1"
    local colors="41 42 43 44 45 46" 
    local length=$(echo -n "$text" | wc -c)
    local duration=3 

    end_time=$((SECONDS + duration))
    while [ $SECONDS -lt $end_time ]; do
        local color_code=$(echo "$colors" | cut -d " " -f $(((end_time - SECONDS) % 6 + 1)))
        printf "\033[${color_code};97m${text}\033[0m"
        sleep 0.5
        printf "\r"
    done
}

animate "--- Nightshade CLI by haxislancelot @ Github ---"
clear

main_menu() {
	clear
	echo -e "\e[44m\e[97mWelcome to Nightshade CLI!\e[0m"
	sleep 0.1
	echo ""
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
    sleep 0.1
    echo "Modes [ 1 ]"
    sleep 0.1
    echo "Plugins [ 2 ]"
    sleep 0.1
    echo "Support [ 3 ]"
    sleep 0.1
    echo ""
    sleep 0.1
    echo -n "Enter your choice: "
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
        *)
            echo "Invalid choice!"
            ;;
    esac            
}
    
mode() {
	clear
    echo -e "\e[44m\e[97m--- Nightshade Modes Menu ---\e[0m"
    sleep 0.1
    echo ""
    sleep 0.1
    echo "Performance [ 1 ]"
    sleep 0.1
    echo "Battery [ 2 ]"
    sleep 0.1
    echo "Balanced [ 3 ]"
    sleep 0.1
    echo "Thermal [ 4 ]"
    sleep 0.1
    echo "Gaming [ 5 ]"
    sleep 0.1
    echo "Return to main menu [ 6 ]"
    sleep 0.1
    echo ""
    sleep 0.1
    echo -n "Enter your choice: "
    read choice

    case $choice in
        1)
            setprop persist.nightshade.mode 4
            sh /sdcard/.tweaks.sh > /dev/null
            mode
            ;;
        2)
            setprop persist.nightshade.mode 2
            sh /sdcard/.tweaks.sh > /dev/null
            mode
            ;;
        3)
            setprop persist.nightshade.mode 3
            sh /sdcard/.tweaks.sh > /dev/null
            mode
            ;;
        4)
            setprop persist.nightshade.mode 6
            sh /sdcard/.tweaks.sh > /dev/null
            mode
            ;;
        5)
            setprop persist.nightshade.mode 5
            sh /sdcard/.tweaks.sh > /dev/null
            mode
            ;;
        6)
            main_menu
            ;;
        *)
            echo "Invalid choice!"
            ;;
    esac
}


# Lista os scripts na pasta /sdcard/.NTSH/plugins e enumera-os
list_plugins() {
    local counter=1
    for plugin in /sdcard/.NTSH/plugins/*.sh; do
        if [ -f "$plugin" ]; then
            plugin_name=$(basename "$plugin" .sh)
            echo "$plugin_name [ $counter ]"
            ((counter++))
            sleep 0.1  # Adiciona um intervalo de 0.1 segundos entre cada plugin
        fi
    done
}

# Função para executar um plugin com base no número fornecido pelo usuário
execute_plugin() {
    local plugin_number=$1
    local plugin_path="/sdcard/.NTSH/plugins/$plugin_number.sh"

    if [ -f "$plugin_path" ]; then
        chmod +x "$plugin_path"
        . "$plugin_path"
    else
        echo "Plugin not found!"
        sleep 2
        plugins
    fi
}

plugins() {
	clear
	echo -e "\e[44m\e[97m--- Nightshade Plugins Menu ---\e[0m"
	echo "Type x to return"
	sleep 0.1
	echo ""
    list_plugins
    echo ""
    sleep 0.1
    
    while true; do
        echo -n "Enter your choice: "
        read selected_plugin_number

        if [ "$selected_plugin_number" == "x" ]; then
            main_menu
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