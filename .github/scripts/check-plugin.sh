#!/usr/bin/env bash
# Checks the marketplaces, the plugin and the MCP Registry entry. Run it from the repository root: .github/scripts/check-plugin.sh [base]
# It needs claude and mcp-publisher on PATH (brew install mcp-publisher, or .github/scripts/install-mcp-publisher.sh).
# With a base commit (CI passes the base branch of the pull request), it also checks that a change to the plugin or to server.json raises the version.
set -euo pipefail

PLUGIN_DIR='plugins/redocly'
REFERENCE="$PLUGIN_DIR/.claude-plugin/plugin.json"
SERVER_JSON='server.json'
base="${1:-}"

fail() {
  echo "$1" >&2
  exit 1
}

# Prints the keys that both JSON values have but with different values. A key in only one of them is not compared.
different_keys() {
  jq -rn --argjson a "$1" --argjson b "$2" \
    '[$a | keys[] | select(. as $key | $b | has($key)) | select($a[.] != $b[.])] | join(", ")'
}

# When the change since the base commit touches the path, checks that the version is higher than the one in the JSON file on the base.
version_raised() {
  local path="$1" file="$2" version="$3" advice="$4" base_version highest
  { [ -n "$base" ] && ! git diff --quiet "$base" HEAD -- "$path" && git cat-file -e "$base:$file" 2> /dev/null; } || return 0
  echo "The version in $file is higher than on $base."
  base_version="$(git show "$base:$file" | jq -r .version)"
  highest="$(printf '%s\n%s\n' "$base_version" "$version" | sort -V | tail -1)"
  if [ "$version" = "$base_version" ] || [ "$highest" != "$version" ]; then
    fail "This change touches $path. Raise the version above $base_version $advice."
  fi
}

echo 'Every JSON file parses.'
git ls-files -z '*.json' | xargs -0 -n1 jq empty

echo 'The plugin manifests share one x.y.z version.'
versions="$(jq -r .version "$PLUGIN_DIR"/.*-plugin/plugin.json | sort -u)"
[[ "$versions" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "Found these versions: ${versions//$'\n'/, }"
version="$versions"

echo 'The MCP server sends the plugin version.'
mcp="$PLUGIN_DIR/.mcp.json"
jq -e --arg version "$version" \
  '[.mcpServers[] | .headers, .http_headers | .["X-Redocly-Plugin-Version"]] | all(. == $version)' "$mcp" > /dev/null \
  || fail "Set X-Redocly-Plugin-Version to $version in headers and http_headers in $mcp."

echo 'Every plugin manifest has a name, a version and a description, and every ./ path in it exists.'
for manifest in "$PLUGIN_DIR"/.*-plugin/plugin.json; do
  jq -e 'has("name") and has("version") and has("description")' "$manifest" > /dev/null \
    || fail "$manifest needs name, version and description."
  while read -r path; do
    [ -e "$PLUGIN_DIR/$path" ] || fail "$manifest points at $path, which does not exist in $PLUGIN_DIR."
  done < <(jq -r '.. | strings | select(startswith("./"))' "$manifest")
done

echo "The plugin manifests and the marketplace entries agree with $REFERENCE."
reference="$(jq -c . "$REFERENCE")"
name="$(jq -r .name <<< "$reference")"
for manifest in "$PLUGIN_DIR"/.*-plugin/plugin.json; do
  keys="$(different_keys "$reference" "$(jq -c . "$manifest")")"
  [ -z "$keys" ] || fail "$manifest has other values for: $keys"
done
for marketplace in .claude-plugin/marketplace.json .cursor-plugin/marketplace.json .agents/plugins/marketplace.json; do
  entry="$(jq -c --arg name "$name" '.plugins[] | select(.name == $name) | del(.source)' "$marketplace")"
  [ -n "$entry" ] || fail "$marketplace has no entry for the plugin $name."
  keys="$(different_keys "$reference" "$entry")"
  [ -z "$keys" ] || fail "The $name entry in $marketplace has other values for: $keys"
done

echo "$SERVER_JSON has the fields that the MCP Registry requires, and its description fits in 100 characters."
jq -e '.name | test("^[a-zA-Z0-9.-]+/[a-zA-Z0-9._-]+$")' "$SERVER_JSON" > /dev/null \
  || fail "$SERVER_JSON needs a name in the form namespace/name."
server_version="$(jq -r .version "$SERVER_JSON")"
[[ "$server_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "$SERVER_JSON needs an x.y.z version."
jq -e '.description | type == "string" and length > 0 and length <= 100' "$SERVER_JSON" > /dev/null \
  || fail "$SERVER_JSON needs a description of 1 to 100 characters."
jq -e '.remotes | length > 0' "$SERVER_JSON" > /dev/null || fail "$SERVER_JSON needs a remote."

echo "$SERVER_JSON points at the MCP server of the plugin, and its icons are images on https URLs."
server_url="$(jq -r '.remotes[0].url' "$SERVER_JSON")"
jq -e --arg url "$server_url" '.mcpServers[] | select(.url == $url)' "$PLUGIN_DIR/.mcp.json" > /dev/null \
  || fail "$SERVER_JSON points at $server_url, which is not in $PLUGIN_DIR/.mcp.json."
while read -r icon; do
  [[ "$icon" == https://* ]] || fail "$SERVER_JSON points at the icon $icon, which is not an https URL."
  curl -fsSIL "$icon" | grep -iq '^content-type: image/' \
    || fail "$SERVER_JSON points at the icon $icon, which does not serve an image."
done < <(jq -r '.icons[]?.src' "$SERVER_JSON")

if [ -n "$base" ]; then
  git rev-parse --verify --quiet "$base^{commit}" > /dev/null || fail "The base $base is not a commit."
fi
version_raised "$PLUGIN_DIR" "$REFERENCE" "$version" 'in every plugin manifest'
version_raised "$SERVER_JSON" "$SERVER_JSON" "$server_version" "in $SERVER_JSON, because the MCP Registry keeps every version it has seen"

echo 'Claude Code accepts the marketplace and the plugin.'
claude plugin validate . --strict
claude plugin validate "./$PLUGIN_DIR" --strict

echo "The MCP Registry accepts $SERVER_JSON."
mcp-publisher validate "$SERVER_JSON"
