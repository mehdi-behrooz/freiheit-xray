#!/bin/sh

case $PROTOCOL in
    tcp) PORT=1081 ;;
    ws) PORT=1082 ;;
    reality) PORT=1083 ;;
esac
export PORT

for f in /etc/xray.d/*;
do
    envsubst < $f | sponge $f
    if [ "$LOG_LEVEL" == "debug" ]
    then
        echo -e "$f: \n"
        cat $f | sed 's/^/\t/'
        echo
    fi
done

exec $@

