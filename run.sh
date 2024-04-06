docker network create --subnet=172.21.0.0/16 openfortivpn
docker rm --force openfortivpn
docker build -t openfortivpn .
docker run --name openfortivpn \
    -p 8020:8020 \
    -e VPN_HOST="" \
    -e SERVER_SIGNATURE="" \
    --network openfortivpn \
    --ip=172.21.0.2 \
    --privileged --cap-add=NET_ADMIN \
    --restart always \
    openfortivpn & 
