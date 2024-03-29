#!/system/bin/sh
# This is experimental and may be buggy.
# This should activate or deactivate the gapps.
# Do not use this in your script or project without asking for my permission.
# https://t.me/donottellmyname

# Colors
F='\033[0m'
G='\033[0;32m'
R='\033[0;31m'
N='\033[0;90m'

doze_tweak() {
	clear
    echo -e "\e[44m\e[97m--- Doze Tweaker by haxislancelot @ Github ---\e[0m"
    sleep 0.1
    echo ""
    echo "\033[0;90mProlong inactivity [ 1 ]"
    sleep 0.1
    echo "Ignore Light Doze [ 2 ]"
    sleep 0.1
    echo "Simulate Deep Doze [ 3 ]"
    sleep 0.1
    echo "Progressive inactivity [ 4 ]"
    sleep 0.1
    echo "Prolonged inactivity [ 5 ]"
    sleep 0.1
    echo "Reset [ 6 ]"
    sleep 0.1
    echo "Exit [ 0 ]"
    echo ""
    sleep 0.1
    echo -ne "${G}Select: ${F}"
    read -s selc
    while true; do
    case $selc in
            1)
                settings put global device_idle_constants inactive_to=2592000000,motion_inactive_to=2592000000
                echo "Done!"
                sleep 1
                doze_tweak
                ;;
            2)
                settings put global device_idle_constants light_after_inactive_to=2592000000
                echo "Done!"
                sleep 1
                doze_tweak
                ;;
            3)
                settings put global device_idle_constants inactive_to=2592000000,motion_inactive_to=2592000000,light_after_inactive_to=3000000,light_max_idle_to=21600000,light_idle_to=3600000,light_idle_maintenance_max_budget=600000,min_light_maintenance_time=30000
                echo "Done!"
                sleep 1
                doze_tweak
                ;;
            4)
                settings put global device_idle_constants inactive_to=2592000000,motion_inactive_to=2592000000,light_after_inactive_to=20000,light_pre_idle_to=30000,light_max_idle_to=86400000,light_idle_to=1800000,light_idle_factor=1.5,light_idle_maintenance_max_budget=30000,light_idle_maintenance_min_budget=10000,min_time_to_alarm=60000
                echo "Done!"
                sleep 1
                doze_tweak
                ;;
            5)
                settings put global device_idle_constants inactive_to=2592000000,motion_inactive_to=2592000000,light_after_inactive_to=15000,light_pre_idle_to=30000,light_max_idle_to=86400000,light_idle_to=43200000,light_idle_maintenance_max_budget=30000,light_idle_maintenance_min_budget=10000,min_time_to_alarm=60000
                echo "Done!"
                sleep 1
                doze_tweak
                ;;
            6)
                settings delete global device_idle_constants
                echo "Done!"
                sleep 1
                doze_tweak
                ;;
            0)
                plugins
                ;;
              *)
                echo -e "\e[41mInvalid choice!\e[0m"
                sleep 1
                doze_tweak
                ;;
            esac 
            break
          done
}

doze_tweak