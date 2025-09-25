#!/bin/bash

output=$(headsetcontrol -b)
battery_percentage=$(echo "$output" | grep -oP 'Level: \d+')

if [[ -n "$battery_percentage" ]]; then
  output="$battery_percentage%"
else
  output="N/A"
fi

echo "$output"
