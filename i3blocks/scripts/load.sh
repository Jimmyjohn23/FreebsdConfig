#!/usr/bin/env bash
# ~/.config/i3blocks/scripts/load.sh

OS=$(uname -s)
if [ "$OS" = "FreeBSD" ]; then
  # FreeBSD: sysctl -n vm.loadavg returns: { 0.27 0.22 0.19 }
  LA=$(sysctl -n vm.loadavg 2>/dev/null)
  # keep only first number
  echo "${LA}" | awk '{gsub(/[{}]/,""); print $1}'
else
  # Linux
  awk '{print $1}' /proc/loadavg 2>/dev/null || uptime | sed -E 's/.*load average: ([0-9.]+).*/\1/'
fi

