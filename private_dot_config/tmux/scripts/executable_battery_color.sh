#!/usr/bin/env bash

status=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1 | tr '[:upper:]' '[:lower:]')
percentage=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)

if [[ "$status" == "charging" ]]; then
  echo "#{E:@thm_blue}"
elif [[ "$status" == "full" ]] || [[ "$status" == "charged" ]]; then
  echo "#{E:@thm_teal}"
elif [[ -z "$percentage" ]] || [[ "$percentage" -ge 80 ]]; then
  echo "#{E:@thm_green}"
elif [[ "$percentage" -ge 20 ]]; then
  echo "#{E:@thm_yellow}"
else
  echo "#{E:@thm_red}"
fi
