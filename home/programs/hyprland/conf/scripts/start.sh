#!/usr/bin/env bash

# Kill already running process
_ps=(waybar mpd dunst)
for _prs in "${_ps[@]}"; do
	if [[ $(pidof ${_prs}) ]]; then
		pkill -9 ${_prs}
	fi
done

swww init &

nm-applet --indicator &

WAYBAR_CONFIG="$HOME/.config/hypr/waybar/config.jsonc"
WAYBAR_STYLE="$HOME/.config/hypr/waybar/style.css"
waybar --bar main-bar --log-level error --config ${WAYBAR_CONFIG} --style ${WAYBAR_STYLE} &

dunst &
udiskie &
exec mpd &
