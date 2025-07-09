#!/system/bin/sh
# This is experimental and may be buggy.
# This should activate or deactivate the gapps.
# Do not use this in your script or project without asking for my permission.
# https://t.me/donottellmyname
clear

# Patch the XML and place the modified one to the original directory
echo -n "\033[1;36m➤ Patching XML's and placing the modified one to the original directory...";
sleep 1

list=$(xml=$(find /system/ /product/ /vendor/ -iname "*.xml");for i in $xml; do if grep -q 'allow-in-power-save package="com.google.android.gms"' $ROOT$i 2>/dev/null; then echo "$i";fi; done)
 for i in $list
 do
 mkdir -p `dirname $MODPATH$i`
 cp -af $ROOT$i $MODPATH$i

 sed -i '/allow-in-power-save package="com.google.android.gms"/d;/allow-in-data-usage-save package="com.google.android.gms"/d' $MODPATH$i

 done

 for i in product vendor
 do
 if [ -d $MODPATH/$i ]; then
 if [ ! -d $MODPATH/system/$i ]; then
 mkdir -p $MODPATH/system/$i
 mv -f $MODPATH/$i $MODPATH/system/
 else
 rm -rf $MODPATH/$i
 fi
 fi
 done

# Search and patch any conflicting modules (if present)
# Search conflicting XML files
echo -n "\033[1;36m➤ Searching and patching any conflicting modules...";

conflict=$(xml=$(find /data/adb -iname "*.xml");for i in $xml; do if grep -q 'allow-in-power-save package="com.google.android.gms"' $i 2>/dev/null; then echo "$i";fi; done)
 for i in $conflict
 do
search=$(echo "$i" | sed -e 's/\// /g' | awk '{print $4}')

 sed -i '/allow-in-power-save package="com.google.android.gms"/d;/allow-in-data-usage-save package="com.google.android.gms"/d' $i

 done
 
# Final message
sleep 0.5
echo ""
echo -e "\033[1;33m➤ Your gms is optimized now!\033[0m"
sleep 0.5
echo -ne "${G}Press ENTER to open plugins...${F}"; read
plugins
