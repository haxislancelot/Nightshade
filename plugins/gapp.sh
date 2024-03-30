#!/system/bin/sh
# This is experimental and may be buggy.
# This should activate or deactivate the gapps.
# Do not use this in your script or project without asking for my permission.
# https://t.me/donottellmyname

disable_menu() {
clear
echo -e "${G}--- Gapps Disabler by haxislancelot @ Github ---${F}"
sleep 0
echo ""
sleep 0
echo "\033[0;90m[ - ] Disable Gapps [ 1 ]"
sleep 0
echo "[ - ] Enable Gapps [ 2 ]"
sleep 0
echo "[ - ] Return to plugins menu [ 0 ]"
sleep 0
echo ""
sleep 0
echo -n "${G}Enter your choice: ${F}"
read choice

case $choice in
    1)
        clear
        pm disable com.google.android.googlequicksearchbox > /dev/null 2>&1
        pm disable com.android.chrome > /dev/null 2>&1
        pm disable com.google.android.apps.photos > /dev/null 2>&1
        pm disable com.google.android.apps.nbu.files > /dev/null 2>&1
        pm disable com.google.android.apps.safetyhub > /dev/null 2>&1
        pm disable com.google.android.apps.wellbeing > /dev/null 2>&1
        echo "${G}Gapps disabled!${F}"
        sleep 1
        disable_menu
        ;;
    2)
        clear
        pm enable com.google.android.googlequicksearchbox > /dev/null 2>&1
        pm enable com.android.chrome > /dev/null 2>&1
        pm enable com.google.android.apps.photos > /dev/null 2>&1
        pm enable com.google.android.apps.nbu.files > /dev/null 2>&1
        pm enable com.google.android.apps.safetyhub > /dev/null 2>&1
        pm enable com.google.android.apps.wellbeing > /dev/null 2>&1
        echo "${G}Gapps enabled!${F}"
        sleep 1
        disable_menu        
        ;;
    0)
        plugins
        ;;
    *)
        echo -e "\e[41mInvalid choice!\e[0m"
        sleep 1
        disable_menu
        ;;
esac
}

disable_menu