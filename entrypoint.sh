#!/bin/bash

for f in /templates/core/*; do
    dest=$(basename "${f%.tmpl}")
    envsubst <"$f" >"/etc/xray/$dest"
done

envsubst <"/templates/$PROTOCOL/inbound.json.tmpl" \
    >/etc/xray/inbound.json

if [ "$LOG_LEVEL" == debug ]; then
    for f in /etc/xray/*; do
        echo -e "$f: \n"
        sed 's/^/\t/' <"$f"
        echo
    done
fi

/usr/bin/generate-config.sh >/output/index.html

if [ "$LOG_LEVEL" == debug ]; then
    echo -e "Configurations: \n"
    sed 's/^/\t/' </output/index.html
    echo
fi

exec "$@"
