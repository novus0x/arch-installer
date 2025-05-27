#!/bin/bash

BAT_PATH="/sys/class/power_supply/BAT1"
if [ ! -d "$BAT_PATH" ]; then
    echo "| "
    exit
fi

capacity=$(cat "$BAT_PATH/capacity")
status=$(cat "$BAT_PATH/status")

icon=""  # default full

if [[ "$status" == "Charging" ]]; then
    icon=""
elif [[ "$status" == "Discharging" ]]; then
    if (( capacity > 80 )); then
        icon=""
    elif (( capacity > 60 )); then
        icon=""
    elif (( capacity > 40 )); then
        icon=""
    elif (( capacity > 20 )); then
        icon=""
    else
        icon=""
    fi
else
    icon=""
fi

echo "| $icon $capacity%"

