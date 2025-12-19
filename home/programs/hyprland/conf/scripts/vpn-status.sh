#!/usr/bin/env bash

VPN="Semcon VPN"

if nmcli -t -f NAME con show --active | grep -q "^$VPN$"; then
  echo "🔒"
else
  echo "🔓"
fi
