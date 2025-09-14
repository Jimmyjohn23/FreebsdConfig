#!/usr/bin/env bash
# ~/.config/i3blocks/scripts/disk.sh
# Usage: disk.sh /mountpoint

mp="${1:-/}"
use=$(df -h "$mp" --output=pcent,target 2>/dev/null | awk 'NR==2{print $1}')
if [ -z "$use" ]; then
  # df option differences: fallback to parsing df -h
  use=$(df -h "$mp" 2>/dev/null | awk 'NR==2{print $5}')
fi
echo " $mp $use"

