# openfortivpn-docker
this container is for SAML authentication
- run the container
- access `https://<vpn-server>/remote/saml/start?redirect=1`
- enjoy


## Usage

run the container using 
```bash
    docker network create --subnet=172.21.0.0/16 openfortivpn
    docker run --name openfortivpn \
    -p 8020:8020 \
    -e VPN_HOST="<vpn-server>" \
    --network openfortivpn \
    --ip=172.21.0.2 \
    --privileged --cap-add=NET_ADMIN \
    --restart always \
    openfortivpn & 
```

## routing
if docker uses 172.17.0.0/16 any you need to route to 172.17.0.0/16 via fortivpn

```bash
cat << EOM >> /etc/docker/daemon.json
{
 "bip": "172.18.0.1/16"
}
EOM
docker service restart
```


add routes in linux
```bash
sudo ip route add 172.17.0.0/16 via 172.21.0.2
sudo ip route replace 172.17.0.0/16 via 172.21.0.2
```

persist routes
```bash
echo "ip route add 172.17.0.0/16 via 172.21.0.2" >> /etc/rc.local
echo "ip route replace 172.17.0.0/16 via 172.21.0.2" >> /etc/rc.local
```

add persisted route in windows 
```bash
route add 172.17.0.0 mask 255.255.0.0 172.21.0.2 -p
```
