#!/bin/sh

case $PROTOCOL in
    tcp) PORT=1081 ;;
    ws) PORT=1082 ;;
    xray) PORT=1083 ;;
esac
export PORT

for f in /etc/xray.d/*;
do
    envsubst < $f | sponge $f
    if [ "$LOG_LEVEL" == "debug" ]
    then
        echo "$f:"
        cat $f
    fi
done

exec $@

