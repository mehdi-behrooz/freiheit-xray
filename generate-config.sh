#!/bin/bash

TCP='vless://$user@$host:443?encryption=none&security=none&type=tcp&headerType=none#$label'

WS='vless://$user@$host:443?encryption=none&security=tls&sni=$sni&alpn=h2&fp=chrome&type=ws&host=$sni&path=$path#$label'

REALITY='vless://$user@$host:443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=$sni&alpn=http%2F1.1&fp=chrome&pbk=$public_key&type=tcp&headerType=none#$label'

encode() {
    printf "$*" | jq -sRr '@uri';
}

if_all() {
    read value
    for condition in "$@"; do
        if [[ $condition == false ]]; then
            return 0
        fi
    done
    echo $value
}

generate() {
    export label=$(encode $2)
    export user=$3
    export host=$4
    export sni=$5
    export path=$6
    export public_key=$7
    url=$(envsubst <<<$1)
    echo $url
}

ipv4=$(curl -s4 ip.sb)
ipv6=$(curl -s6 ip.sb)

[[ $GENERATE_DIRECT_CONFIGS == true ]] || direct=false
[[ $GENERATE_TUNNEL_CONFIGS == true ]] || tunnel=false
[[ $GENERATE_WORKER_CONFIGS == true ]] || worker=false
[[ $GENERATE_IPV4_CONFIGS == true ]] || genipv4=false
[[ $GENERATE_IPV6_CONFIGS == true ]] || genipv6=false
[[ $GENERATE_WARP_CONFIGS == true ]] || warp=false

case $PROTOCOL in

tcp)
    generate $TCP "TCP" $USER_ID_DIRECT ${ipv4:-[$ipv6]} | if_all $direct
    generate $TCP "TCP #" $USER_ID_WARP ${ipv4:-[$ipv6]} | if_all $direct $warp
    generate $TCP "Tunnel" $USER_ID_DIRECT $TUNNEL_IP | if_all $tunnel
    generate $TCP "Tunnel #" $USER_ID_WARP $TUNNEL_IP | if_all $tunnel $warp
;;

ws)
    generate $WS "WS" $USER_ID_DIRECT $CLOUDFLARE_IP $WS_HOST $WS_PATH | if_all $direct
    generate $WS "WS #" $USER_ID_WARP $CLOUDFLARE_IP $WS_HOST $WS_PATH | if_all $direct $warp
    generate $WS "Worker" $USER_ID_DIRECT $CLOUDFLARE_IP $WORKER_SNI $WS_PATH | if_all $worker
    generate $WS "Worker #" $USER_ID_WARP $CLOUDFLARE_IP $WORKER_SNI $WS_PATH | if_all $worker $warp
;;

reality)
    generate $REALITY "Reality v4" $USER_ID_DIRECT $ipv4 $REALITY_SNI 0 $REALITY_PUBLIC_KEY | if_all $ipv4 $genipv4
    generate $REALITY "Reality v4 #" $USER_ID_WARP $ipv4 $REALITY_SNI 0 $REALITY_PUBLIC_KEY | if_all $ipv4 $genipv4 $warp
    generate $REALITY "Reality v6" $USER_ID_DIRECT [$ipv6] $REALITY_SNI 0 $REALITY_PUBLIC_KEY | if_all $ipv6 $genipv6
    generate $REALITY "Reality v6 #" $USER_ID_WARP [$ipv6] $REALITY_SNI 0 $REALITY_PUBLIC_KEY | if_all $ipv6 $genipv6 $warp
;;

esac
