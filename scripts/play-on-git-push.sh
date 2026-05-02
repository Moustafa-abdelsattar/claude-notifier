#!/bin/bash
# play-on-git-push.sh
# PostToolUse hook for Bash. Reads tool JSON from stdin and plays auraa.mp3
# whenever the executed command actually pushes code to a remote.
#
# Matches:
#   * literal "git push" (git push origin main, etc.)
#   * any command containing "--push" as a flag (e.g. `gh repo create --push`,
#     `gh repo sync --push`) — so it still fires when gh CLI handles the push.
#
# Honors config.json overrides: if the GitPush event is disabled or has a
# different sound, that wins. See scripts/notify-config.sh.

if grep -qE '"command"\s*:\s*"[^"]*(git[[:space:]]+push|--push([[:space:]"]|$))' <<< "$(cat)"; then
  bash "${CLAUDE_PLUGIN_ROOT}/scripts/play-sound.sh" auraa.mp3 GitPush
fi

exit 0
