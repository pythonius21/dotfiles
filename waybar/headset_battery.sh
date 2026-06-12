#!/bin/bash

output=$(headsetcontrol -b 2>/dev/null)
battery_percentage=$(echo "$output" | grep -oP 'Level:\s*\K\d+')
charging_status=$(echo "$output" | grep -oP 'Status:\s*\K\w+')

if [[ -z "$battery_percentage" ]]; then
  echo "N/A"
  exit 0
fi

if [[ "$charging_status" == BATTERY_CHARGING ]]; then
  echo "󰂄 Charging: ${battery_percentage}%"
else
  echo " Battery: ${battery_percentage}%"
fi
