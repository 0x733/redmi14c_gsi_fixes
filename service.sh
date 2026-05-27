#!/system/bin/sh
until [ "$(getprop sys.boot_completed)" -eq 1 ]; do
    sleep 1
done
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
