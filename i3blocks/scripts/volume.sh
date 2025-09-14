#!/usr/bin/env bash
# ~/.config/i3blocks/scripts/volume.sh

OS=$(uname -s)
icon=""

if [ "$OS" = "FreeBSD" ]; then
  # use mixer (we saw this on your system)
  if command -v mixer >/dev/null 2>&1; then
    # get pcm volume (formats vary; try pcm)
    val=$(mixer pcm 2>/dev/null | awk -F= '/pcm.volume/ {print $2}' | tr -d ' %')
    # if mixer returned something like "pcm.volume=0.61:0.61", convert to percent
    if echo "$val" | grep -q ":"; then
      left=$(echo "$val" | cut -d: -f1)
      # as fraction 0.61 -> 61%
      pct=$(awk -v v="$left" 'BEGIN{printf "%d", v*100}')
    else
      pct=$(echo "$val" | sed 's/[^0-9]//g')
    fi
    # mute check
    mute=$(mixer pcm | awk -F= '/pcm.mute/ {print $2}')
    [ "$mute" = "on" ] && echo "🔇" && exit 0
    echo "$icon ${pct:-?}%"
    exit 0
  fi
fi

# Linux flows
if command -v amixer >/dev/null 2>&1; then
  # try ALSA amixer
  out=$(amixer get Master)
  if echo "$out" | grep -q '\[off\]'; then
    echo "🔇"
  else
    pct=$(echo "$out" | awk -F'[][]' '/%/ {print $2; exit}' | tr -d '%')
    echo "$icon ${pct:-?}%"
  fi
  exit 0
fi

if command -v pactl >/dev/null 2>&1; then
  s=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | head -n1)
  pct=$(echo "$s" | grep -o '[0-9]\+%' | head -n1 | tr -d '%')
  mute=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}')
  [ "$mute" = "yes" ] && echo "🔇" && exit 0
  echo "$icon ${pct:-?}%"
  exit 0
fi

echo "$icon n/a"

