FROM ghcr.io/home-assistant/base:latest

RUN apk add --no-cache curl jq

# Install and verify patched cloudflared
RUN curl -fL \
    https://github.com/cloudflare/cloudflared/releases/download/2026.11.0/cloudflared-linux-amd64 \
    -o /usr/bin/cloudflared && \
    echo "51f7c68b57ed7269164075d7e789efce5b59355982f06392deeb037d982a51fd  /usr/bin/cloudflared" | sha256sum -c - && \
    chmod +x /usr/bin/cloudflared && \
    /usr/bin/cloudflared --version

ENV HOSTNAME="HAOS-Machine"

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
