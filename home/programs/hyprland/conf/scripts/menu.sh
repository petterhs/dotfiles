#!/usr/bin/env bash

CONFIG="$HOME/.config/hypr/wofi/config.jsonc"
STYLE="$HOME/.config/hypr/wofi/style.css"
if [[ ! $(pidof wofi) ]]; then
  wofi --show=drun --conf "${CONFIG}" --style "${STYLE}" --allow-images
else
	pkill wofi 
fi
