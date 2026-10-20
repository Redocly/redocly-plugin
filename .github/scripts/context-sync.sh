#!/usr/bin/env bash
# Mirrors the skills that redocly.com publishes into plugins/redocly/skills.
# Run it from the repository root. When they are set, it writes changed, version and title to $GITHUB_OUTPUT,
# and the pull request body to $SYNC_BODY_FILE.
set -euo pipefail

SKILLS_BASE_URL="${SKILLS_BASE_URL:-https://redocly.com/.well-known/agent-skills}"
PLUGIN_DIR='plugins/redocly'

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT
index="$work_dir/index.json"

fail() {
  echo "$1" >&2
  exit 1
}

write_output() {
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "$1" >> "$GITHUB_OUTPUT"
  fi
}

fetch() {
  curl --fail --silent --show-error --location --max-time 60 --retry 2 "$1" --output "$2"
}

check_version() {
  local versions
  versions="$(jq -r .version "$PLUGIN_DIR"/.*-plugin/plugin.json | sort -u)"
  [[ "$versions" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] \
    || fail "The plugin manifests must share one x.y.z version. Found: ${versions//$'\n'/, }"
  local manifest
  for manifest in "$PLUGIN_DIR"/.*-plugin/plugin.json; do
    grep -qF "\"version\": \"$versions\"" "$manifest" || fail "$manifest must write the version as \"version\": \"$versions\"."
  done
  mcp_has_version "$versions" || fail "$PLUGIN_DIR/.mcp.json must send X-Redocly-Plugin-Version: $versions."
}

check_index() {
  jq -e '.skills | type == "array" and length > 0' "$index" > /dev/null || fail 'The skills index has no skills.'
  local invalid duplicates
  invalid="$(jq -r --arg base "$SKILLS_BASE_URL" '
    .skills[]
    | select(
        ((.name | type == "string" and test("^[a-z0-9]+(-[a-z0-9]+)*$"))
          and .type == "skill-md"
          and .url == "\($base)/\(.name)/SKILL.md"
          and (.digest | type == "string" and test("^sha256:[0-9a-f]{64}$")))
        | not)
    | .name // "(no name)"
  ' "$index")"
  [ -z "$invalid" ] || fail "The skills index has invalid entries: ${invalid//$'\n'/, }"
  duplicates="$(jq -r '[.skills[].name] | group_by(.) | map(select(length > 1)[0]) | join(", ")' "$index")"
  [ -z "$duplicates" ] || fail "The skills index lists these skills more than once: $duplicates"
}

download_skills() {
  local name digest file
  mkdir "$work_dir/skills"
  while IFS=$'\t' read -r name digest; do
    file="$work_dir/skills/$name/SKILL.md"
    mkdir "$work_dir/skills/$name"
    fetch "$SKILLS_BASE_URL/$name/SKILL.md" "$file"
    [ "sha256:$(sha256sum < "$file" | cut -d ' ' -f 1)" = "$digest" ] \
      || fail "The skill \"$name\" does not match its digest in the index."
  done < <(jq -r '.skills[] | [.name, .digest] | @tsv' "$index")
}

list_skills() {
  find "$1" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
}

changed_skills() {
  local name
  while read -r name; do
    diff -r "$PLUGIN_DIR/skills/$name" "$work_dir/skills/$name" > /dev/null || echo "$name"
  done < <(comm -12 <(list_skills "$PLUGIN_DIR/skills") <(list_skills "$work_dir/skills"))
}

format_names() {
  # shellcheck disable=SC2016 # The backticks are Markdown, not a command.
  sed 's/.*/`&`/' | paste -sd ',' - | sed 's/,/, /g'
}

mcp_has_version() {
  jq -e --arg version "$1" \
    '[.mcpServers[] | .headers, .http_headers | .["X-Redocly-Plugin-Version"]] | all(. == $version)' \
    "$PLUGIN_DIR/.mcp.json" > /dev/null
}

raise_patch_version() {
  local current next manifest
  current="$(jq -r .version "$PLUGIN_DIR/.claude-plugin/plugin.json")"
  next="${current%.*}.$((${current##*.} + 1))"
  for manifest in "$PLUGIN_DIR"/.*-plugin/plugin.json; do
    sed -i.bak -E "s/\"version\": \"$current\"/\"version\": \"$next\"/" "$manifest"
    rm "$manifest.bak"
    [ "$(jq -r .version "$manifest")" = "$next" ] || fail "Could not set the version in $manifest."
  done
  sed -i.bak -E "s/\"X-Redocly-Plugin-Version\": \"$current\"/\"X-Redocly-Plugin-Version\": \"$next\"/" "$PLUGIN_DIR/.mcp.json"
  rm "$PLUGIN_DIR/.mcp.json.bak"
  mcp_has_version "$next" || fail "Could not set X-Redocly-Plugin-Version in $PLUGIN_DIR/.mcp.json."
  echo "$next"
}

write_body() {
  [ -n "${SYNC_BODY_FILE:-}" ] || return 0
  {
    echo "This pull request mirrors the skills that redocly.com publishes at $SKILLS_BASE_URL/index.json, and raises the plugin version to $version. Each file matches its SHA-256 digest in the index."
    echo
    if [ -n "$removed" ]; then
      echo "- **Removed:** $(format_names <<< "$removed"). redocly.com no longer lists these skills. Make sure that this is intended: Realm also leaves a skill out of the index when an access rule hides it or when its front matter does not parse."
    fi
    if [ -n "$added" ]; then
      echo "- **Added:** $(format_names <<< "$added")"
    fi
    if [ -n "$changed" ]; then
      echo "- **Changed:** $(format_names <<< "$changed")"
    fi
    echo
    # shellcheck disable=SC2016
    echo 'Do not push to this branch. The next run rebuilds it from `main` and replaces any commit on it.'
  } > "$SYNC_BODY_FILE"
}

check_version
fetch "$SKILLS_BASE_URL/index.json" "$index"
check_index
download_skills

added="$(comm -13 <(list_skills "$PLUGIN_DIR/skills") <(list_skills "$work_dir/skills"))"
removed="$(comm -23 <(list_skills "$PLUGIN_DIR/skills") <(list_skills "$work_dir/skills"))"
changed="$(changed_skills)"

if [ -z "$added$removed$changed" ]; then
  echo 'The skills are up to date.'
  write_output 'changed=false'
  exit 0
fi

rm -rf "$PLUGIN_DIR/skills"
mv "$work_dir/skills" "$PLUGIN_DIR/skills"
version="$(raise_patch_version)"
title='chore: sync skills from redocly.com'
if [ -n "$removed" ]; then
  title="$title (removes ${removed//$'\n'/, })"
fi
write_body

echo "The skills changed. The new plugin version is $version."
write_output 'changed=true'
write_output "version=$version"
write_output "title=$title"
