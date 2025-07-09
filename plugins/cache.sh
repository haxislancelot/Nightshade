#!/system/bin/sh
# This is experimental and may be buggy.
# This should activate or deactivate the gapps.
# Do not use this in your script or project without asking for my permission.
# https://t.me/donottellmyname
clear

sleep 0.5
free | awk '/Mem/{print "\033[1;36m➤ Free memory before boosting : "$4/1024" MB";}'
echo "";
sleep 0.5
echo -n "➤ Boosting your Android !! Please wait!!";
sync;
echo -n ".";
sleep 0.5
echo "3" > /proc/sys/vm/drop_caches;
am kill-all
sleep 0.5
echo -n ".";
echo "";
echo "➤ Clearing all caches\033[0m"
sleep 0.5
echo ""
free | awk '/Mem/{print "\033[1;36m➤ Free memory after impulse! : "$4/1024" MB";}'
echo ""
sleep 0.5
echo "\033[1;33m➤ Done!!! Your device is now optimized !!\033[0m";
sleep 0.5
echo -ne "${G}Press ENTER to open plugins...${F}"; read
plugins
