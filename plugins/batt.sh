#!/bin/bash
# This is experimental and may be buggy.
# This creates a dashboard to monitor your battery and a menu with options for energy efficiency.
# Do not use this in your script or project without asking for my permission.
# https://t.me/donottellmyname

# Function to display key battery information
battery_info() {
	clear
	sleep 0
    echo "${G}Your Battery Information:${F}"
    echo ""
    sleep 0
    capacity=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null)
    if [ -n "$capacity" ]; then
        echo "\033[0;90m[ - ] Capacity: $capacity%"
        sleep 0
    fi

    status=$(cat /sys/class/power_supply/battery/status 2>/dev/null)
    if [ -n "$status" ]; then
        echo "[ - ] Status: $status"
        sleep 0
    fi

    health=$(cat /sys/class/power_supply/battery/health 2>/dev/null)
    if [ -n "$health" ]; then
        echo "[ - ] Health: $health"
        sleep 0
    fi

    temperature=$(cat /sys/class/power_supply/battery/temp 2>/dev/null)
    if [ -n "$temperature" ]; then
        temperature=$(echo "scale=1; $temperature / 10" | bc)
        echo "[ - ] Temperature: $temperature°C"
        sleep 0
    fi

    voltage=$(cat /sys/class/power_supply/battery/voltage_now 2>/dev/null)
    if [ -n "$voltage" ]; then
        voltage=$(echo "scale=2; $voltage / 1000000" | bc)
        echo "[ - ] Voltage: $voltage V"
        sleep 0
    fi

    cycle_count=$(cat /sys/class/power_supply/battery/cycle_count 2>/dev/null)
    if [ -n "$cycle_count" ]; then
        echo "[ - ] Cycle Count: $cycle_count"
        sleep 0
    fi

    technology=$(cat /sys/class/power_supply/battery/technology 2>/dev/null)
    if [ -n "$technology" ]; then
        echo "[ - ] Technology: $technology"
        sleep 0
    fi
    
    # Battery menu code
    current_mode=$(settings get global low_power)
    if [ "$current_mode" == "1" ]; then
        power_saving_option="Disable"
    else
        power_saving_option="Enable"
    fi

    background_apps_mode=$(settings get global background_process_limit)
    if [ "$background_apps_mode" == "1" ]; then
        background_apps_option="Disable"
    else
        background_apps_option="Enable"
    fi

    location_services_mode=$(settings get secure location_mode)
    if [ "$location_services_mode" == "1" ]; then
        location_services_option="Disable"
    else
        location_services_option="Enable"
    fi
    echo ""
    sleep 0
    echo "[ - ] $power_saving_option Power Saving Mode [ 1 ]"
    sleep 0
    echo "[ - ] Adjust Screen Brightness [ 2 ]"
    sleep 0
    echo "[ - ] $background_apps_option Background Apps [ 3 ]"
    sleep 0
    echo "[ - ] $location_services_option Location Services [ 4 ]"
    sleep 0
    echo "[ - ] Return to plugins menu [ 0 ]"
    sleep 0
    echo ""
    sleep 0
    echo -n "${G}Select an option: ${F}"
    read option
    case $option in
        1) toggle_power_saving ;;
        2) reduce_brightness ;;
        3) toggle_background_apps ;;
        4) toggle_location_services ;;
        0) plugins ;;
        *) echo -e "\e[41mInvalid choice!\e[0m"; sleep 1; battery_menu ;;
    esac
}

# Function to switch power saving mode
toggle_power_saving() {
    current_mode=$(settings get global low_power)
    if [ "$current_mode" == "1" ]; then
        settings put global low_power 0
        echo "${G}Power Saving Mode Disabled!${F}"
        sleep 1
        battery_menu
    else
        settings put global low_power 1
        echo "${G}Power Saving Mode Enabled!"
        sleep 1
        battery_menu
    fi
}

# Function to reduce screen brightness
reduce_brightness() {
    settings put system screen_brightness 30
    echo "${G}Screen Brightness Adjusted!${F}"
    sleep 1
    battery_menu
}

# Function to switch background applications
toggle_background_apps() {
    background_apps_mode=$(settings get global background_process_limit)
    if [ "$background_apps_mode" == "1" ]; then
        settings put global background_process_limit 0
        echo "${G}Background Apps Enabled!${F}"
        sleep 1
        battery_menu
    else
        settings put global background_process_limit 1
        echo "${G}Background Apps Disabled!${F}"
        sleep 1
        battery_menu
    fi
}

# Function to switch location services
toggle_location_services() {
    location_services_mode=$(settings get secure location_mode)
    if [ "$location_services_mode" == "1" ]; then
        settings put secure location_mode 0
        echo "${G}Location Services Disbled!${F}"
        sleep 1
        battery_menu
    else
        settings put secure location_mode 1
        echo "${G}Location Services Enabled!${F}"
        sleep 1
        battery_menu
    fi
}

# Exibir informações principais da bateria
battery_info
