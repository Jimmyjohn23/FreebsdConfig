#!/usr/bin/env bash
# ~/.config/i3blocks/scripts/music.sh

if command -v mpc >/dev/null 2>&1; then
  status=$(mpc status 2>/dev/null)
  song=$(mpc current)
  if echo "$status" | grep -q '\[playing\]'; then
    echo " $song"
  elif echo "$status" | grep -q '\[paused\]'; then
    echo " $song"
  else
    echo " stopped"
  fi
  exit 0
fi

if command -v playerctl >/dev/null 2>&1; then
  state=$(playerctl status 2>/dev/null)
  if [ "$state" = "Playing" ]; then
    track=$(playerctl metadata --format '{{artist}} - {{title}}' 2>/dev/null)
    echo " $track"
  else
    echo ""
  fi
  exit 0
fi

echo ""

