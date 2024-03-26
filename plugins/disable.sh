#!/system/bin/sh
# This is experimental and may be buggy.
# This should activate or deactivate the gapps.
# Do not use this in your script or project without asking for my permission.
# https://t.me/donottellmyname

menu() {
clear
echo "--- Gapps Disabler by haxislancelot @ Github ---"
sleep 0.2
echo ""
sleep 0.2
echo "Disable Gapps [ 1 ]"
sleep 0.2
echo "Enable Gapps [ 2 ]"
sleep 0.2
echo "Exit [ 0 ]"
sleep 0.2
echo ""
sleep 0.2
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
        menu
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
        menu        
        ;;
    0)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice. Please enter 0, 1, or 2."
        ;;
esac
}

menu