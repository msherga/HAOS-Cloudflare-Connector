ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install jq for parsing options and curl for downloading the binary
RUN apk add --no-cache curl jq

# Download the latest cloudflared binary
RUN curl -L \
  https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
  -o /usr/bin/cloudflared && chmod +x /usr/bin/cloudflared

# Set default environment variable
ENV HOSTNAME="HAOS-Machine"

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD [ "/run.sh" ]