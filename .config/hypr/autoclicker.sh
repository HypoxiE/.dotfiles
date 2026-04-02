#!/usr/bin/env bash

PIDFILE="/tmp/autoclicker.pid"

if [ -f "$PIDFILE" ]; then
    kill "$(cat $PIDFILE)" 2>/dev/null
    rm "$PIDFILE"
    exit 0
fi

(
    while true; do
        ydotool click 0xC0
        sleep 0.05
    done
) &

echo $! > "$PIDFILE"