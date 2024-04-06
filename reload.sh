#!/bin/bash

USER_AGENT=${USER_AGENT:-"User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko)"}
TIMEOUT=${TIMEOUT:-10}

echo -e "HTTP/1.1 200 OK\r\n"
echo -e "Content-Type: text/html\r\n"

read -r line

if [[ ! $line =~ ^GET\ \/\?\id=[a-zA-Z0-9]+\ HTTP/1\.1 ]]; then
    echo "bad request"
    exit 1
fi



session_id=$(echo $line | cut -d'=' -f2 | cut -d' ' -f1)
if ! echo "$session_id" | grep -Eq '^[a-zA-Z0-9]{1,64}$'; then
    echo "Invalid session_id: $session_id"
fi

response=$(curl -k -i -s \
    -H "$USER_AGENT" \
    --no-keepalive \
    https://forti.bento.ro/remote/saml/auth_id?id=${session_id})


if [[ ! $response =~ ^HTTP/1\.1\ 200\ OK ]]; then
    echo "<!DOCTYPE html><html><head><body style=\"color:red\"><pre>$response</pre></body></html>"
    exit 1
fi

cookie_value=$(echo "$response" | grep -i 'Set-Cookie' | cut -d' ' -f2 | cut -d';' -f1)

if [[ ! $cookie_value =~ ^SVPNCOOKIE= ]]; then
    echo "<!DOCTYPE html><html><head><body style=\"color:red\"><h1>BAD COOKIE FORMAT</h1><p>$cookie_valye</p></body></html>"
    exit 1
fi

cookie_value=${cookie_value#SVPNCOOKIE=}
pgrep openfortivpn | while read pid; do kill $pid; wait $pid; done
sleep 1

mkfifo mypipe

openfortivpn $VPN_HOST \
    --trusted-cert $SERVER_SIGNATURE \
    --cookie="SVPNCOOKIE=${cookie_value}" > mypipe 2>&1 &

echo "<!DOCTYPE html><html><head><body><pre>"
timeout $TIMEOUT cat mypipe
rm mypipe
echo "</pre></body></html>"

exit 0
