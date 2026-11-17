FROM ghcr.io/home-assistant/base:latest

RUN apk add --no-cache curl jq

# Install and verify patched cloudflared
RUN curl -fL \
    https://github.com/cloudflare/cloudflared/releases/download/2026.11.1/cloudflared-linux-amd64 \
    -o /usr/bin/cloudflared && \
    echo "97bb3b02d23a5980fc9c15a1a270e692da1923f103f920d5b16d4931d5ab55e7  /usr/bin/cloudflared" | sha256sum -c - && \
    chmod +x /usr/bin/cloudflared && \
    /usr/bin/cloudflared --version

ENV HOSTNAME="HAOS-Machine"

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
