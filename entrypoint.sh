#!/bin/bash

for f in /templates/core/*; do
    envsubst <"$f" >"/etc/xray.d/$(basename ${f%.tmpl})"
done

envsubst <"/templates/$PROTOCOL/inbound.json.tmpl" \
        >/etc/xray.d/inbound.json

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

