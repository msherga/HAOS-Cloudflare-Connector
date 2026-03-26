#!/bin/sh
set -e

echo "==== Starting Cloudflare Tunnel Connector ===="

# 1. Get whatever the user pasted into the UI
RAW_INPUT="$(jq -r '.token // empty' /data/options.json)"

if [ -z "$RAW_INPUT" ] || [ "$RAW_INPUT" = "null" ]; then
  echo "ERROR: No Cloudflare tunnel token provided. Please go to the Configuration tab."
  exit 1
fi

# 2. Logic to strip the command down to just the token
# This looks for a long string of characters (the token) at the end of the input
# It works whether they paste the full command or just the token.
TOKEN=$(echo "$RAW_INPUT" | awk '{print $NF}')

# 3. Security/Validation check
# Cloudflare tokens are usually very long. If it's too short, something is wrong.
if [ ${#TOKEN} -lt 30 ]; then
  echo "ERROR: The extracted token seems too short. Please check your input."
  exit 1
fi

echo "Successfully processed token (Length: ${#TOKEN})"

# 4. Set Hostname
export HOSTNAME="HAOS-Machine"
export TUNNEL_ORIGIN_CERT_HOSTNAME="HAOS-Machine"

echo "Connecting to Cloudflare as: $HOSTNAME"

# 5. Launch
exec /usr/bin/cloudflared tunnel --no-autoupdate run --token "$TOKEN"