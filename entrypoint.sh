#!/bin/bash

iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE

while true; do  
    echo "Starting openfortivpn"
    nc -lp 8020 -e /root/reload.sh
    sleep 1
done    
