FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    curl \
    busybox \
    openfortivpn \
    iptables \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /bin/busybox /bin/nc

RUN echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

COPY reload.sh /root/reload.sh
RUN chmod +x /root/reload.sh
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

ENTRYPOINT [ "/root/entrypoint.sh" ]