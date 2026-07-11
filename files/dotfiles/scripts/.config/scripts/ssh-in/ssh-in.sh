#!/bin/bash

# Incoming SSH sessions (this machine as the server).
# Click to see who's connected and from where.

SESSIONS=$(ss -tnp state established 2>/dev/null | grep 'sshd')
COUNT=$(echo -n "$SESSIONS" | grep -c .)

if [ "$1" = "--details" ]; then
    if [ "$COUNT" -eq 0 ]; then
        notify-send "SSH In" "No incoming connections"
    else
        DETAILS=$(echo "$SESSIONS" | awk '{print "from " $4}' | sed 's/:[0-9]*$//')
        notify-send "SSH In ($COUNT)" "$DETAILS"
    fi
    exit 0
fi

echo "󰢹 $COUNT"
