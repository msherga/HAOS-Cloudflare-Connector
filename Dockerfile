FROM ghcr.io/home-assistant/base:latest

RUN apk add --no-cache curl jq

# Install and verify patched cloudflared
RUN curl -fL \
    https://github.com/cloudflare/cloudflared/releases/download/2026.10.7/cloudflared-linux-amd64 \
    -o /usr/bin/cloudflared && \
    echo "1f99fb518b83dec2ba8d870a7cc991d82a77e6196295a3d2754ba17ab9f91872  /usr/bin/cloudflared" | sha256sum -c - && \
    chmod +x /usr/bin/cloudflared && \
    /usr/bin/cloudflared --version

ENV HOSTNAME="HAOS-Machine"

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
