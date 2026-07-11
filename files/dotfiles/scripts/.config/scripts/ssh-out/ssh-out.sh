#!/bin/bash

# Outgoing SSH sessions (this machine as the client).
# Click to see what's connected and to where.

SESSIONS=$(ss -tnp state established 2>/dev/null | grep -E '"ssh"')
COUNT=$(echo -n "$SESSIONS" | grep -c .)

if [ "$1" = "--details" ]; then
    if [ "$COUNT" -eq 0 ]; then
        notify-send "SSH Out" "No outgoing connections"
    else
        DETAILS=$(echo "$SESSIONS" | awk '{print "to " $4}' | sed 's/:[0-9]*$//')
        notify-send "SSH Out ($COUNT)" "$DETAILS"
    fi
    exit 0
fi

echo "󰣀 $COUNT"
