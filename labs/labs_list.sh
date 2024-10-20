#!/bin/bash
# Do not use this in your script or project without asking for my permission.
# https://t.me/donottellmyname

# Download all scripts and then allocate them
chipset=$(grep "Hardware" /proc/cpuinfo | uniq | cut -d ':' -f 2 | sed 's/^[ \t]*//')
if [ -z "$chipset" ]; then
    chipset=$(getprop "ro.hardware")
fi

if [[ $chipset == *s5e8825* ]]; then
    curl -o /sdcard/.NTSH/labs/switch_rcu.sh "https://raw.githubusercontent.com/haxislancelot/Nightshade/beta/labs/switch_rcu.sh" > /dev/null 2>&1
    am start -a android.intent.action.MAIN -e toasttext "Labs scripts updated successfully!" -n bellavita.toast/.MainActivity
else
    am start -a android.intent.action.MAIN -e toasttext "Labs scripts updated successfully!" -n bellavita.toast/.MainActivity
fi