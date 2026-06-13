#!/system/bin/sh
ui_print "*************************************"
ui_print " Redmi 14C GSI Fixes & Audio Booster "
ui_print " by 0x733 & reiryuki                 "
ui_print " (Combined by Antigravity)           "
ui_print "*************************************"
ui_print " Optimizations for Android 16 & GSI  "
ui_print "*************************************"

# aml.sh rename
if [ -f "$MODPATH/aml.sh" ]; then
  mv -f "$MODPATH/aml.sh" "$MODPATH/.aml.sh"
fi

# Run Reiryuki's copy and patch scripts if they exist
ui_print "- Running universal volume booster patcher..."
MODSYSTEM=/system
if [ -f "$MODPATH/copy.sh" ]; then
  . "$MODPATH/copy.sh"
fi
if [ -f "$MODPATH/.aml.sh" ]; then
  . "$MODPATH/.aml.sh"
fi
ui_print "- Universal patches applied."
