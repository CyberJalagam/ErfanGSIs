#!/bin/bash

systempath=$1
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# AOSP libs
cp -fpr $thispath/overlay/* $1/product/overlay/

# Copy changes in system folder
rsync -ra $thispath/system/ $1

# Append file_context
echo "ro.config.ringtone=The_big_adventure.ogg" >> $1/product/etc/build.prop
echo "ro.config.notification_sound=Popcorn.ogg" >> $1/product/etc/build.prop
echo "ro.config.alarm_alert=Bright_morning.ogg" >> $1/product/etc/build.prop
echo "persist.sys.overlay.pixelrecents=true" >> $1/product/etc/build.prop
echo "qemu.hw.mainkeys=0" >> $1/product/etc/build.prop
echo "ro.opa.eligible_device=true" >> $1/product/etc/build.prop
echo "ro.atrace.core.services=com.google.android.gms,com.google.android.gms.ui,com.google.android.gms.persistent" >> $1/product/etc/build.prop
echo "ro.com.android.dataroaming=false" >> $1/product/etc/build.prop
echo "ro.com.google.clientidbase=android-google" >> $1/product/etc/build.prop
echo "ro.error.receiver.system.apps=com.google.android.gms" >> $1/product/etc/build.prop
echo "ro.com.google.ime.theme_id=5" >> $1/product/etc/build.prop
echo "ro.com.google.ime.system_lm_dir=/product/usr/share/ime/google/d3_lms" >> $1/product/etc/build.prop
sed -i "/dataservice_app/d" $1/product/etc/selinux/product_seapp_contexts
sed -i "/dataservice_app/d" $1/system_ext/etc/selinux/system_ext_seapp_contexts
sed -i "/ro.sys.sdcardfs/d" $1/product/etc/build.prop

# Drop HbmSVManager which is crashing light hal
rm -rf $1/system_ext/priv-app/HbmSVManager

# Fix boot
rm -rf $1/../init.environ.rc
cp -vrp $thispath/init.environ.rc $1/../init.environ.rc

# Fix decrypted issue (maybe?)
echo "rm -rf /data/system/storage.xml" >> $1/bin/cppreopts.sh
rm -rf $1/product/etc/security/avb

# Enable Sexy theme by default
echo "ro.boot.vendor.overlay.theme=com.google.android.systemui.gxoverlay" >> $1/product/etc/build.prop

# More fixes
echo "ro.com.google.ime.height_ratio=1.0" >> $1/product/etc/build.prop
sed -i "s/ro.debuggable=0/ro.debuggable=1/g" $1/build.prop
sed -i "s/persist.sys.usb.config=none/persist.sys.usb.config=adb/g" $1/system_ext/etc/build.prop
sed -i "/on property:vendor.sys.usb.adb.disabled/d " $1/etc/init/hw/init.usb.rc
sed -i "/setprop sys.usb.adb.disabled/d " $1/etc/init/hw/init.usb.rc
