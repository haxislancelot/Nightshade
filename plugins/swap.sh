#!/system/bin/sh
# This is experimental and may be buggy.
# This creates or deletes swaps.
# Do not use this in your script or project without asking for my permission.
# https://t.me/donottellmyname

swap_menu() {
	clear
    echo -e "${G}--- Swap Creator by haxislancelot @ Github ---${F}"
    sleep 0
    echo ""
    echo "\033[0;90mCustom Swap Size [ 1 ]"
    sleep 0
    echo "Delete Swap [ 2 ]"
    sleep 0
    echo "Return to plugins menu [ 0 ]"
    echo ""
    sleep 0
    echo -ne "${G}Select: ${F}"
    read -s mswap
    while true; do
    case $mswap in
            1)
                echo -ne "${G}Swap Size (MB):${F} "
                read -s swap_size
                echo -ne "${G}Do you want to swap with size $swap_size MB? enter (y/n):${F} "
                read -s choice
                if [ "$choice" == "y" ]; then
                echo ""
                dd if=/dev/zero of=/data/local/tmp/swap bs=1048576 count=$swap_size
                mkswap /data/local/tmp/swap
                free
                else
                echo ""
                fi
                ;;
            2)
                rm -f /data/local/tmp/swap
                echo "${G}Swap deleted successfully!${F}"
                sleep 1
                swap_menu
                ;;
            0)
                plugins
                ;;
              *)
                echo -e "\e[41mInvalid choice!\e[0m"
                sleep 1
                main_menu
                ;;
            esac 
            break
          done
}

swap_menu