#!/bin/bash

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

generate_tcp() {
    export label=$(encode $1)
    export user=$2
    export host=$3
    envsubst <$uri
}

generate_ws() {
    export label=$(encode $1)
    export user=$2
    export host=$CLOUDFLARE_IP
    export path=$WS_PATH
    export sni=$3
    envsubst <$uri
}

generate_reality() {
    export label=$(encode $1)
    export user=$2
    export host=$3
    export reality_sni=$REALITY_SNI
    export public_key=$REALITY_PUBLIC_KEY
    envsubst <$uri
}

ipv4=$(curl -s4 ip.sb)
ipv6=$(curl -s6 ip.sb)
if [[ -n $ipv6 ]]; then ipv6=[$ipv6]; fi
ip=${ipv4:-$ipv6}

uri="/templates/$PROTOCOL/uri"

case $PROTOCOL in

tcp)
    [[ $GENERATE_DIRECT_CONFIGS == true ]] || direct=false
    [[ $GENERATE_TUNNEL_CONFIGS == true ]] || tunnel=false
    [[ $GENERATE_WARP_CONFIGS == true ]] || warp=false
    generate_tcp "TCP"      $USER_ID_DIRECT $ip        | if_all $direct
    generate_tcp "TCP #"    $USER_ID_WARP   $ip        | if_all $direct $warp
    generate_tcp "Tunnel"   $USER_ID_DIRECT $TUNNEL_IP | if_all $tunnel
    generate_tcp "Tunnel #" $USER_ID_WARP   $TUNNEL_IP | if_all $tunnel $warp
;;

ws)
    [[ $GENERATE_DIRECT_CONFIGS == true ]] || direct=false
    [[ $GENERATE_WORKER_CONFIGS == true ]] || worker=false
    [[ $GENERATE_WARP_CONFIGS == true ]] || warp=false
    generate_ws "WS"       $USER_ID_DIRECT $WS_HOST    | if_all $direct
    generate_ws "WS #"     $USER_ID_WARP   $WS_HOST    | if_all $direct $warp
    generate_ws "Worker"   $USER_ID_DIRECT $WORKER_SNI | if_all $worker
    generate_ws "Worker #" $USER_ID_WARP   $WORKER_SNI | if_all $worker $warp
;;

reality)
    [[ $GENERATE_IPV4_CONFIGS == true ]] || genipv4=false
    [[ $GENERATE_IPV6_CONFIGS == true ]] || genipv6=false
    [[ $GENERATE_WARP_CONFIGS == true ]] || warp=false
    generate_reality "Reality v4"   $USER_ID_DIRECT $ipv4 | if_all $ipv4 $genipv4
    generate_reality "Reality v4 #" $USER_ID_WARP   $ipv4 | if_all $ipv4 $genipv4 $warp
    generate_reality "Reality v6"   $USER_ID_DIRECT $ipv6 | if_all $ipv6 $genipv6
    generate_reality "Reality v6 #" $USER_ID_WARP   $ipv6 | if_all $ipv6 $genipv6 $warp
;;

esac
