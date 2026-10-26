FROM ghcr.io/home-assistant/base:3.24

RUN apk add --no-cache curl jq

# Download the pinned cloudflared release and verify its published SHA-256.
RUN curl -fL \
    https://github.com/cloudflare/cloudflared/releases/download/2026.10.4/cloudflared-linux-amd64 \
    -o /usr/bin/cloudflared && \
    echo "ae5e8add7884b0531d66bbca4570d1de491ff6da51e4ebe7eb160cdf241d9e42  /usr/bin/cloudflared" | sha256sum -c - && \
    chmod +x /usr/bin/cloudflared && \
    /usr/bin/cloudflared --version

ENV HOSTNAME="HAOS-Machine"

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
