#!/usr/bin/env bash

if [[ ! $(pidof rofi) ]]; then
	rofi -show drun -show-icons
else
	pkill rofi 
fi
