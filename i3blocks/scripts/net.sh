#!/usr/bin/env bash
# ~/.config/i3blocks/scripts/net.sh

OS=$(uname -s)

if [ "$OS" = "FreeBSD" ]; then
  # find the first UP, non-loopback inet interface
  iface=$(ifconfig -l 2>/dev/null | tr ' ' '\n' | while read -r ifn; do
    if ifconfig "$ifn" | grep -q 'inet '; then
      # skip lo0
      [ "$ifn" = "lo0" ] && continue
      echo "$ifn" && break
    fi
  done)
  if [ -n "$iface" ]; then
    ip=$(ifconfig "$iface" inet | awk '/inet / {print $2; exit}')
    echo " $iface: ${ip:-?}"
  else
    echo " down"
  fi
else
  # Linux: prefer ip command
  if command -v ip >/dev/null 2>&1; then
    iface=$(ip -4 addr show up scope global | awk '/inet/ {print $NF; exit}')
    ip=$(ip -4 addr show up scope global | awk '/inet/ {print $2; exit}')
    [ -n "$iface" ] && echo " $iface: ${ip%%/*}" || echo " down"
  else
    echo " n/a"
  fi
fi

