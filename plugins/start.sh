#!/system/bin/sh
clear

# Função para animar o texto com cores que mudam automaticamente
animate() {
    local text="$1"
    local colors="41 42 43 44 45 46"  # Cores de fundo ANSI: vermelho, verde, amarelo, azul, magenta, ciano
    local length=$(echo -n "$text" | wc -c)
    local duration=3  # Duração da animação em segundos

    end_time=$((SECONDS + duration))
    while [ $SECONDS -lt $end_time ]; do
        local color_code=$(echo "$colors" | cut -d " " -f $(((end_time - SECONDS) % 6 + 1)))
        printf "\033[${color_code};97m${text}\033[0m"
        sleep 0.5  # Ajuste este valor para controlar a velocidade da animação
        printf "\r"
    done
}

# Exemplo de uso da função animate
animate "--- Nightshade CLI by haxislancelot @ Github ---"

clear
main_menu() {
	clear
	echo "Welcome to Nightshade CLI!"
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
            validate_password && mode
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

validate_password() {
    echo -n "Enter the password: "
    read password
    if [ "$password" != "ntshnihil" ]; then
        echo "Incorrect password."
        sleep 2
        main_menu
    fi
}
    
mode() {
	clear
    echo -e "\033[44;97;1mWhich mode do you want to apply?\033[0m"
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

main_menu