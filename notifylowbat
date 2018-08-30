#!/usr/bin/env bash
set -euo pipefail

POWERSUPPLY="/sys/class/power_supply/BAT1/status"
TOO_LOW=30
LOWEST=5
NOT_CHARGING="Discharging"
ICON="/usr/share/icons/HighContrast/48x48/status/battery-caution.png"

export DISPLAY=:0

BATTERY_LEVEL=$(acpi -b | grep -P -o '[0-9]+(?=%)')
STATUS=$(cat $POWERSUPPLY)

if [ "$BATTERY_LEVEL" -le "$TOO_LOW" ] && [ "$STATUS" = "$NOT_CHARGING" ]; then
    /usr/bin/notify-send -u critical -i "$ICON" "Battery low" "Battery level is ${BATTERY_LEVEL}%!"
    exit 0
fi

if [ "$BATTERY_LEVEL" -le "$LOWEST" ] && [ "$STATUS" = "$NOT_CHARGING" ]; then
    /usr/sbin/shutdown -h now
    exit 0
fi


exit 0

