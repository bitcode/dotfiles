#!/bin/bash

# Auto-detect whichever interface currently owns the default route (works
# with NetworkManager, systemd-networkd, dhcpcd, etc. — no nmcli dependency).
IFACE=$(ip route show default 2>/dev/null | awk '/default/ {print $5; exit}')
IP_ADDRESS=$(ip -4 -o addr show "$IFACE" 2>/dev/null | awk '{print $4}' | cut -d/ -f1)

if [ -n "$IP_ADDRESS" ]; then
    echo "$IFACE: $IP_ADDRESS"
else
    echo "--------"
fi
