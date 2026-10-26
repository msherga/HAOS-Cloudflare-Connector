#!/usr/bin/env python3
"""Open an app update PR when Cloudflare publishes a newer stable cloudflared."""

import json
import re
import urllib.request
from pathlib import Path

API = "https://api.github.com/repos/cloudflare/cloudflared/releases/latest"
BINARY = "cloudflared-linux-amd64"

request = urllib.request.Request(
    API,
    headers={
        "Accept": "application/vnd.github+json",
        "User-Agent": "HAOS-Cloudflare-Connector-updater",
    },
)
with urllib.request.urlopen(request, timeout=30) as response:
    release = json.load(response)

new_version = release["tag_name"]
if not re.fullmatch(r"\d{4}\.\d{1,2}\.\d+", new_version):
    raise RuntimeError(f"Unexpected cloudflared release tag: {new_version!r}")

asset = next((item for item in release["assets"] if item["name"] == BINARY), None)
if asset is None:
    raise RuntimeError(f"Cloudflare release {new_version} has no {BINARY} asset")

digest = asset.get("digest") or ""
if not re.fullmatch(r"sha256:[a-f0-9]{64}", digest):
    raise RuntimeError("Cloudflare release asset does not provide a valid SHA-256 digest")
new_sha = digest.removeprefix("sha256:")

dockerfile = Path("Dockerfile")
old_docker = dockerfile.read_text(encoding="utf-8")
version_match = re.search(
    r"cloudflare/cloudflared/releases/download/(\d{4}\.\d{1,2}\.\d+)/cloudflared-linux-amd64",
    old_docker,
)
checksum_match = re.search(r'([a-f0-9]{64})(?=  /usr/bin/cloudflared")', old_docker)
if not version_match or not checksum_match:
    raise RuntimeError("Dockerfile lacks the expected pinned version or checksum")

old_version = version_match.group(1)
if tuple(map(int, new_version.split("."))) <= tuple(map(int, old_version.split("."))):
    print(f"Already current: pinned {old_version}, latest stable {new_version}")
    raise SystemExit(0)

old_url = (
    f"https://github.com/cloudflare/cloudflared/releases/download/"
    f"{old_version}/{BINARY}"
)
new_url = (
    f"https://github.com/cloudflare/cloudflared/releases/download/"
    f"{new_version}/{BINARY}"
)
if old_docker.count(old_url) != 1:
    raise RuntimeError("Expected exactly one pinned cloudflared download URL")

config_path = Path("config.yaml")
old_config = config_path.read_text(encoding="utf-8")
app_match = re.search(r'(?m)^version: "(\d+)\.(\d+)\.(\d+)"$', old_config)
if not app_match:
    raise RuntimeError("Expected numeric major.minor.patch app version in config.yaml")
major, minor, patch = map(int, app_match.groups())
old_app = f"{major}.{minor}.{patch}"
new_app = f"{major}.{minor}.{patch + 1}"

new_docker = old_docker.replace(old_url, new_url)
new_docker = new_docker.replace(checksum_match.group(1), new_sha, 1)
new_config = old_config.replace(f'version: "{old_app}"', f'version: "{new_app}"', 1)

changelog_path = Path("CHANGELOG.md")
old_changelog = changelog_path.read_text(encoding="utf-8")
new_entry = (
    f"## {new_app}\n"
    f"- Updated cloudflared from {old_version} to {new_version}.\n\n"
)

dockerfile.write_text(new_docker, encoding="utf-8")
config_path.write_text(new_config, encoding="utf-8")
changelog_path.write_text(new_entry + old_changelog, encoding="utf-8")
print(f"Prepared app {new_app}: cloudflared {old_version} -> {new_version}")
