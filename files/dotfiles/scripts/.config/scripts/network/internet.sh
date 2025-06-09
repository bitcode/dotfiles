#!/bin/bash

# Function to get IP address
get_ip_address() {
    local iface=$1
    nmcli -t -f IP4.ADDRESS dev show "$iface" | grep -oP '(\d+\.\d+\.\d+\.\d+)' | head -n1
}

# Check Ethernet connection (enp3s0)
ETH_INTERFACE="enp3s0"
ETH_IP_ADDRESS=$(get_ip_address "$ETH_INTERFACE")

# Display result
if [ -n "$ETH_IP_ADDRESS" ]; then
    echo "$ETH_INTERFACE: $ETH_IP_ADDRESS"
else
    echo "--------"
fi

