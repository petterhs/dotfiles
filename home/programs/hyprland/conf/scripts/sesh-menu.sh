#!/usr/bin/env bash

CONFIG="$HOME/.config/hypr/wofi/config.jsonc"
STYLE="$HOME/.config/hypr/wofi/style.css"

# Use $TERMINAL if set, otherwise fall back to alacritty
TERM_CMD="${TERMINAL:-alacritty}"

# Get list of sesh targets and pipe into wofi dmenu-style picker
SESH_SELECTION="$(sesh list | wofi --dmenu --conf "${CONFIG}" --style "${STYLE}" --prompt 'sesh ' )"

# If user picked something, open a terminal connected to that session
if [[ -n "$SESH_SELECTION" ]]; then
  exec "$TERM_CMD" -e sesh connect "$SESH_SELECTION"
fi



