#!/usr/bin/env bash
# Opens, updates or closes the context sync pull request. The Context sync workflow runs it after context-sync.sh.
# Needs GH_TOKEN, APP_SLUG, SYNC_BRANCH and CHANGED; when CHANGED is true, also TITLE and BODY_FILE.
set -euo pipefail

open_pr="$(gh pr list --head "$SYNC_BRANCH" --state open --json number,isCrossRepository \
  --jq 'map(select(.isCrossRepository | not))[0].number // empty')"

if [ "$CHANGED" != 'true' ]; then
  if [ -n "$open_pr" ]; then
    # shellcheck disable=SC2016 # The backticks are Markdown, not a command.
    gh pr close "$open_pr" --delete-branch \
      --comment 'redocly.com publishes the same skills as `main` again, so this pull request is not needed.'
  fi
  exit 0
fi

user_id="$(gh api "/users/${APP_SLUG}%5Bbot%5D" --jq .id)"
git config user.name "${APP_SLUG}[bot]"
git config user.email "${user_id}+${APP_SLUG}[bot]@users.noreply.github.com"
git switch --create "$SYNC_BRANCH"
git add --all plugins/redocly
git commit --quiet --message 'chore: sync skills from redocly.com'

if [ -n "$open_pr" ] && git fetch --quiet origin "$SYNC_BRANCH" && git diff --quiet FETCH_HEAD HEAD; then
  echo "Pull request #$open_pr already has these changes."
  exit 0
fi

git push --force origin "$SYNC_BRANCH"
if [ -n "$open_pr" ]; then
  gh pr edit "$open_pr" --title "$TITLE" --body-file "$BODY_FILE"
else
  gh pr create --base main --head "$SYNC_BRANCH" --title "$TITLE" --body-file "$BODY_FILE"
fi
