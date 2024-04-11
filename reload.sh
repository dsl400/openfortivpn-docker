#!/bin/bash

USER_AGENT=${USER_AGENT:-"User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko)"}
TIMEOUT=${TIMEOUT:-10}

echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n"
GREEN="<!DOCTYPE html><html><head><style>body{color: #33ff00; background-color:black; }</style></head><body>"
RED="<!DOCTYPE html><html><head><style>body{color: red; background-color:black; }</style></head><body>"


read -r line

if [[ ! $line =~ ^GET\ \/\?\id=[a-zA-Z0-9]+\ HTTP/1\.1 ]]; then
    echo "${RED}<h1>bad request</h1>"
    exit 1
fi



session_id=$(echo $line | cut -d'=' -f2 | cut -d' ' -f1)
if ! echo "$session_id" | grep -Eq '^[a-zA-Z0-9]{1,64}$'; then
    echo "${RED}<h1>Invalid session_id: $session_id</h1>"
    exit 1
fi

response=$(curl -k -i -s \
    -H "$USER_AGENT" \
    --no-keepalive \
    ${VPN_HOST}/remote/saml/auth_id?id=${session_id})


if [[ ! $response =~ ^HTTP/1\.1\ 200\ OK ]]; then
    echo "$response"
    exit 1
fi

cookie_value=$(echo "$response" | grep -i 'Set-Cookie' | cut -d' ' -f2 | cut -d';' -f1)

if [[ ! $cookie_value =~ ^SVPNCOOKIE= ]]; then
    echo "${RED}<h1>BAD COOKIE FORMAT</h1><pre>$cookie_valye</pre>"
    exit 1
fi

cookie_value=${cookie_value#SVPNCOOKIE=}
pgrep openfortivpn | while read pid; do pkill $pid; done
while pgrep openfortivpn > /dev/null; do sleep 1; done

mkfifo mypipe

openfortivpn $VPN_HOST \
    --trusted-cert=$SERVER_SIGNATURE \
    --cookie="SVPNCOOKIE=${cookie_value}" > mypipe 2>&1 &
echo "${GREEN}<pre>"
timeout $TIMEOUT cat mypipe
rm mypipe
echo "</pre></body></html>"

exit 0
