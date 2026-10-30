## 1.1.2
- Updated cloudflared from 2026.10.4 to 2026.10.7.

## 1.1.0
- Transitioned from local app to github-hosted.

## 1.0.4
- "tag" still didn't work so switched to the cloudflare env variable `TUNNEL_ORIGIN_CERT_HOSTNAME`.

## 1.0.3
- Fixed incorrect flag usage (changed -tag to --tag).
- Added custom hostname "HAOS-Machine" reporting.
- Improved token validation logic in run script.

## 1.0.2
- Added custom hostname "HAOS-Machine" to the connector.
- Forced hostname reporting via environment variables and CLI tags.
- Optimized run script to use `set -e` for better error handling.

## 1.0.1
- Fixed name of app.
- Set debug for exploration into functionality.
- Token set as "password" field type.

## 1.0.0
- Initial release of the Cloudflared Connector.
- Only exists as a local app for now