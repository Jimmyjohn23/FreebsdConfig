#!/usr/bin/env bash
# Simple FreeBSD-only battery script for i3blocks

# Icons (requires Nerd Font)
IC_CHRG=""   # charging
IC_FULL=""   # full
IC_3=""      # 60%
IC_2=""      # 40%
IC_1=""      # 20%
IC_UNKNOWN=""

# Try sysctl first
percent=$(sysctl -n hw.acpi.battery.life 2>/dev/null)
state=$(sysctl -n hw.acpi.battery.state 2>/dev/null)

# If sysctl fails, fallback to acpiconf
if [ -z "$percent" ] || [ "$percent" -lt 0 ]; then
    output=$(acpiconf -i 0 2>/dev/null)
    # extract Remaining capacity: XX%
    percent=$(echo "$output" | awk -F': ' '/Remaining capacity/ {print $2}' | tr -d '%')
    # detect charging
    if echo "$output" | grep -qi 'charging'; then
        state="charging"
    fi
fi

# Default icon selection
if [ -n "$percent" ]; then
    pct=${percent%%.*}
    if [ "$pct" -ge 95 ]; then icon="$IC_FULL"
    elif [ "$pct" -ge 60 ]; then icon="$IC_3"
    elif [ "$pct" -ge 40 ]; then icon="$IC_2"
    elif [ "$pct" -ge 15 ]; then icon="$IC_1"
    else icon="$IC_1"
    fi
    [ "$state" = "charging" ] && icon="$IC_CHRG"
    echo "$icon $pct%"
else
    echo "$IC_UNKNOWN n/a"
fi

