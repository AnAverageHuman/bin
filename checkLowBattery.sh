#!/usr/bin/env bash
set -euo pipefail

POWERSUPPLY="/sys/class/power_supply/BAT1/status"
TOO_LOW=30
NOT_CHARGING="Discharging"
ICON="/usr/share/icons/HighContrast/48x48/status/battery-caution.png"

export DISPLAY=:0

BATTERY_LEVEL=$(acpi -b | grep -P -o '[0-9]+(?=%)')
STATUS=$(cat $POWERSUPPLY)

if [ "$BATTERY_LEVEL" -le "$TOO_LOW" ] && [ "$STATUS" = "$NOT_CHARGING" ]; then
    /usr/bin/notify-send -u critical -i "$ICON" "Battery low" "Battery level is ${BATTERY_LEVEL}%!"
fi

exit 0

