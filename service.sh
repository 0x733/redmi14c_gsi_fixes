#!/system/bin/sh
# Redmi 14C GSI Fixes & Audio Booster Service

MODPATH=${0%/*}
exec 2>$MODPATH/debug.log
set -x

# Wait for boot
until [ "$(getprop sys.boot_completed)" -eq 1 ]; do
    sleep 1
done

# Original performance tweaks
echo "512" > /sys/block/mmcblk0/queue/read_ahead_kb
for queue in /sys/block/dm-*/queue/read_ahead_kb; do
    echo "512" > "$queue" 2>/dev/null
done
echo "5" > /proc/sys/vm/dirty_background_ratio
echo "20" > /proc/sys/vm/dirty_ratio
echo "80" > /proc/sys/vm/vfs_cache_pressure

settings put system peak_refresh_rate 120.0
settings put system min_refresh_rate 120.0

echo 1 > /sys/module/ged/parameters/boost_gpu_enable
echo 400000 > /sys/module/ged/parameters/gpu_bottom_freq
echo 400000 > /sys/module/ged/parameters/gpu_cust_boost_freq
echo 950000 > /sys/module/ged/parameters/gpu_cust_upbound_freq

# Reiryuki's service logic (restarting audioserver)
API=`getprop ro.build.version.sdk`
if [ ! -d $MODPATH/vendor ] || [ -L $MODPATH/vendor ]; then
  MODSYSTEM=/system
fi

if [ "$API" -ge 24 ]; then
  SERVER=audioserver
else
  SERVER=mediaserver
fi

# Restart audio server to apply the parameters
killall $SERVER\
 android.hardware.audio@4.0-service-mediatek\
 android.hardware.audio.service 2>/dev/null

# aml fix
AML=/data/adb/modules/aml
DIR=$AML$MODSYSTEM/vendor/odm/etc
if [ "$API" -ge 26 ] && [ -d $DIR ] && [ ! -f $AML/disable ]; then
  chcon -R u:object_r:vendor_configs_file:s0 $DIR 2>/dev/null
fi

AUD=`grep AUD= $MODPATH/copy.sh | sed -e 's|AUD=||g' -e 's|"||g'`
DIR=$AML$MODSYSTEM/vendor
FILES=`find $DIR -type f -name $AUD 2>/dev/null`
if [ -d $AML ] && [ ! -f $AML/disable ] && find $DIR -type f -name $AUD >/dev/null 2>&1; then
  if ! grep -q '/odm' $AML/post-fs-data.sh && [ -d /odm ] && [ "`realpath /odm/etc 2>/dev/null`" == /odm/etc ]; then
    for FILE in $FILES; do
      DES=/odm`echo $FILE | sed "s|$DIR||g"`
      if [ -f $DES ]; then
        umount $DES 2>/dev/null
        mount -o bind $FILE $DES
      fi
    done
  fi
  if ! grep -q '/my_product' $AML/post-fs-data.sh && [ -d /my_product ]; then
    for FILE in $FILES; do
      DES=/my_product`echo $FILE | sed "s|$DIR||g"`
      if [ -f $DES ]; then
        umount $DES 2>/dev/null
        mount -o bind $FILE $DES
      fi
    done
  fi
fi
