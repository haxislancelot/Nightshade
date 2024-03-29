#!/system/bin/sh
# This is experimental and may be buggy.
# This should activate or deactivate the gapps.
# Do not use this in your script or project without asking for my permission.
# https://t.me/donottellmyname

disable_menu() {
clear
echo -e "\e[44m\e[97m--- Gapps Disabler by haxislancelot @ Github ---\e[0m"
sleep 0.1
echo ""
sleep 0.1
echo "Disable Gapps [ 1 ]"
sleep 0.1
echo "Enable Gapps [ 2 ]"
sleep 0.1
echo "Exit [ 0 ]"
sleep 0.1
echo ""
sleep 0.1
echo -n "Enter your choice: "
read choice

case $choice in
    1)
        clear
        pm disable com.google.android.googlequicksearchbox > /dev/null
        pm disable com.android.chrome > /dev/null
        pm disable com.google.android.apps.photos > /dev/null
        pm disable com.google.android.apps.nbu.files > /dev/null
        pm disable com.google.android.apps.safetyhub > /dev/null
        pm disable com.google.android.apps.wellbeing > /dev/null
        echo "Gapps disabled!"
        sleep 1
        disable_menu
        ;;
    2)
        clear
        pm enable com.google.android.googlequicksearchbox > /dev/null
        pm enable com.android.chrome > /dev/null
        pm enable com.google.android.apps.photos > /dev/null
        pm enable com.google.android.apps.nbu.files > /dev/null
        pm enable com.google.android.apps.safetyhub > /dev/null
        pm enable com.google.android.apps.wellbeing > /dev/null
        echo "Gapps enabled!"
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