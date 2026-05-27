#!/system/bin/sh
resetprop ro.audio.ignore_effects true
resetprop persist.sys.qcom-brightness 4095
resetprop ro.telephony.block_binder_thread_on_incoming_calls false
resetprop sys.use_fifo_ui 1
resetprop debug.hwui.renderer skiaogl
resetprop ro.max.fling_velocity 20000
resetprop ro.min.fling_velocity 8000
resetprop dalvik.vm.heapstartsize 16m
