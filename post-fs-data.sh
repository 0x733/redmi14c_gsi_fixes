#!/system/bin/sh
# Redmi 14C GSI Fixes Post-FS-Data

# Original fixes
resetprop ro.audio.ignore_effects true
resetprop persist.sys.qcom-brightness 4095
resetprop ro.telephony.block_binder_thread_on_incoming_calls false
resetprop sys.use_fifo_ui 1
resetprop debug.hwui.renderer skiaogl
resetprop ro.max.fling_velocity 20000
resetprop ro.min.fling_velocity 8000
resetprop dalvik.vm.heapstartsize 16m
resetprop debug.sf.disable_backpressure 1
resetprop debug.sf.latch_unsignaled 1

# Reiryuki's volume booster logic
mount -o rw,remount /data
MODPATH=${0%/*}
exec 2>$MODPATH/debug-pfsd.log
set -x

API=`getprop ro.build.version.sdk`
if [ ! -d $MODPATH/vendor ] || [ -L $MODPATH/vendor ]; then
  MODSYSTEM=/system
fi

# Run copy and patch
if [ -f "$MODPATH/copy.sh" ]; then
  . "$MODPATH/copy.sh"
fi
if [ -f "$MODPATH/.aml.sh" ]; then
  . "$MODPATH/.aml.sh"
fi

# Android 16 SELinux & Permissions Fix
chown -R 0:0 "$MODPATH/system"
find "$MODPATH/system" -type d -exec chmod 755 {} \;
find "$MODPATH/system" -type f -exec chmod 644 {} \;

if [ "$API" -ge 26 ]; then
  DIRS=`find $MODPATH/vendor $MODPATH/system/vendor -type d 2>/dev/null`
  for DIR in $DIRS; do
    chown 0.2000 $DIR
  done
  
  # Contexts
  chcon -R u:object_r:vendor_file:s0 $MODPATH$MODSYSTEM/vendor 2>/dev/null
  chcon -R u:object_r:vendor_configs_file:s0 $MODPATH$MODSYSTEM/vendor/etc 2>/dev/null
  chcon -R u:object_r:system_file:s0 $MODPATH/system/etc 2>/dev/null
  
  if [ -d "$MODPATH/system/odm/etc" ]; then
    chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/system/odm/etc 2>/dev/null
  fi
  if [ -d "$MODPATH/system/vendor/odm/etc" ]; then
    chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/system/vendor/odm/etc 2>/dev/null
  fi
fi

# Bind mounts for odm/my_product (if any mixer files were copied there)
mount_odm() {
  DIR=$MODPATH/system/odm
  FILES=`find $DIR -type f -name $AUD 2>/dev/null`
  for FILE in $FILES; do
    DES=/odm`echo $FILE | sed "s|$DIR||g"`
    if [ -f $DES ]; then
      umount $DES 2>/dev/null
      mount -o bind $FILE $DES
    fi
  done
}
mount_my_product() {
  DIR=$MODPATH/system/my_product
  FILES=`find $DIR -type f -name $AUD 2>/dev/null`
  for FILE in $FILES; do
    DES=/my_product`echo $FILE | sed "s|$DIR||g"`
    if [ -f $DES ]; then
      umount $DES 2>/dev/null
      mount -o bind $FILE $DES
    fi
  done
}

AUD=`grep AUD= $MODPATH/copy.sh | sed -e 's|AUD=||g' -e 's|"||g'`
if [ -d /odm ] && [ "`realpath /odm/etc 2>/dev/null`" == /odm/etc ]\
&& ! grep -q /odm /data/adb/magisk/magisk 2>/dev/null\
&& ! grep -q /odm /data/adb/magisk/magisk64 2>/dev/null\
&& ! grep -q /odm /data/adb/magisk/magisk32 2>/dev/null; then
  mount_odm
fi
if [ -d /my_product ]\
&& ! grep -q /my_product /data/adb/magisk/magisk 2>/dev/null\
&& ! grep -q /my_product /data/adb/magisk/magisk64 2>/dev/null\
&& ! grep -q /my_product /data/adb/magisk/magisk32 2>/dev/null; then
  mount_my_product
fi
