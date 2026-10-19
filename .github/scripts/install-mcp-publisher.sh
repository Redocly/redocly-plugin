#!/usr/bin/env bash
# Installs the pinned mcp-publisher release, the CLI of the MCP Registry: .github/scripts/install-mcp-publisher.sh [directory]
# The directory defaults to a temporary one. In GitHub Actions the directory goes on the PATH of the following steps.
# To update: raise VERSION and copy the checksums from the registry_<version>_checksums.txt asset of the release.
set -euo pipefail

VERSION='1.8.1'
# https://github.com/modelcontextprotocol/registry/releases/download/v1.8.1/registry_1.8.1_checksums.txt
CHECKSUMS='
a06c9096dcb9727c13555b6be26c7effa707b01f06a4c561ba7a3635443cf2cc  mcp-publisher_linux_amd64.tar.gz
8dd75a6cf6845688b5d4e46df58d3ca26d5c8d233bb0626606e1db82c5e883e4  mcp-publisher_linux_arm64.tar.gz
88126981225e7714fcc6b7a10cdba4a80ae5901e9740a8c06d0d5195c8bc294c  mcp-publisher_darwin_amd64.tar.gz
e45e520892460732a4bdf37255576415d4a53ec171f8b913faf15bb1aef7cb77  mcp-publisher_darwin_arm64.tar.gz
'

fail() {
  echo "$1" >&2
  exit 1
}

directory="${1:-${RUNNER_TEMP:-${TMPDIR:-/tmp}}/mcp-publisher}"
os="$(uname -s | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')"
archive="mcp-publisher_${os}_${arch}.tar.gz"
expected="$(awk -v archive="$archive" '$2 == archive { print $1 }' <<< "$CHECKSUMS")"
[ -n "$expected" ] || fail "No checksum for $archive. Add it to $0."

mkdir -p "$directory"
curl -fsSL --retry 3 -o "$directory/$archive" \
  "https://github.com/modelcontextprotocol/registry/releases/download/v$VERSION/$archive"
actual="$( (sha256sum "$directory/$archive" 2> /dev/null || shasum -a 256 "$directory/$archive") | cut -d ' ' -f 1)"
[ "$actual" = "$expected" ] || fail "$archive has the checksum $actual, expected $expected."
tar -xzf "$directory/$archive" -C "$directory" mcp-publisher
rm "$directory/$archive"

[ -z "${GITHUB_PATH:-}" ] || echo "$directory" >> "$GITHUB_PATH"
echo "mcp-publisher $VERSION is in $directory"
