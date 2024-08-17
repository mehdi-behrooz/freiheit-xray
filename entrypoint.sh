#!/bin/bash

for f in $(ls /app/xray/core/); do
    envsubst < /app/xray/core/$f > /etc/xray.d/$f
done

f="inbound-$PROTOCOL.json"
envsubst < "/app/xray/inbounds/$f" > "/etc/xray.d/$f"

if [ $LOG_LEVEL == debug ]; then
    for f in /etc/xray.d/*; do
        echo -e "$f: \n"
        cat $f | sed 's/^/\t/'
        echo
    done
fi

/usr/bin/generate-config.sh > /output/index.html

if [ $LOG_LEVEL == debug ]; then
    echo -e "Configurations: \n"
    cat /output/index.html | sed 's/^/\t/'
    echo
fi

exec $@

