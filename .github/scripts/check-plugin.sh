#!/usr/bin/env bash
# Checks the marketplaces and the plugin. Run it from the repository root: .github/scripts/check-plugin.sh [base]
# With a base commit (CI passes the base branch of the pull request), it also checks that a change to the plugin raises the version.
set -euo pipefail

PLUGIN_DIR='plugins/redocly'
REFERENCE="$PLUGIN_DIR/.claude-plugin/plugin.json"
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

echo 'Every JSON file parses.'
git ls-files -z '*.json' | xargs -0 -n1 jq empty

echo 'The plugin manifests share one x.y.z version.'
versions="$(jq -r .version "$PLUGIN_DIR"/.*-plugin/plugin.json | sort -u)"
[[ "$versions" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "Found these versions: ${versions//$'\n'/, }"
version="$versions"

echo 'The MCP server sends the same headers to every client, with the plugin version.'
mcp="$PLUGIN_DIR/.mcp.json"
jq -e '[.mcpServers[] | .headers == .http_headers] | all' "$mcp" > /dev/null \
  || fail "$mcp must have equal headers and http_headers: Claude Code and Cursor read headers, Codex reads http_headers."
jq -e --arg version "$version" '[.mcpServers[].headers["X-Redocly-Plugin-Version"]] | all(. == $version)' "$mcp" > /dev/null \
  || fail "Set X-Redocly-Plugin-Version to $version in $mcp."

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

if [ -n "$base" ]; then
  git rev-parse --verify --quiet "$base^{commit}" > /dev/null || fail "The base $base is not a commit."
fi
if [ -n "$base" ] && ! git diff --quiet "$base" HEAD -- "$PLUGIN_DIR" && git cat-file -e "$base:$REFERENCE" 2> /dev/null; then
  echo "The version is higher than on $base."
  base_version="$(git show "$base:$REFERENCE" | jq -r .version)"
  highest="$(printf '%s\n%s\n' "$base_version" "$version" | sort -V | tail -1)"
  if [ "$version" = "$base_version" ] || [ "$highest" != "$version" ]; then
    fail "This change touches $PLUGIN_DIR. Raise the version above $base_version in every plugin manifest."
  fi
fi

echo 'Claude Code accepts the marketplace and the plugin.'
claude plugin validate . --strict
claude plugin validate "./$PLUGIN_DIR" --strict
