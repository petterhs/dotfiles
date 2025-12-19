#!/usr/bin/env bash

VPN="Semcon VPN"

if nmcli -t -f NAME,TYPE,DEVICE con show --active | grep -q "^$VPN"; then
  nmcli con down "$VPN"
else
  nmcli con up "$VPN"
fi
