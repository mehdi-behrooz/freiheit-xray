#!/bin/bash

mkdir /etc/xray.d/

for f in $(ls /app/xray/core/); do
    envsubst < /app/xray/core/$f > /etc/xray.d/$f
done

envsubst < "/app/xray/inbounds/inbound-$PROTOCOL.json" > "/etc/xray.d/inbound-$PROTOCOL.json"

if [ "$LOG_LEVEL" == "debug" ]; then
    for f in /etc/xray.d/*; do
        echo -e "$f: \n"
        cat $f | sed 's/^/\t/'
        echo
    done
fi

exec $@

