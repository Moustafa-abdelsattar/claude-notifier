#!/bin/bash
# play-on-git-push.sh
# PostToolUse hook for Bash. Reads JSON from stdin and plays auraa.mp3
# only if the executed command contains "git push".

if grep -qE '"command"\s*:\s*"[^"]*git[[:space:]]+push' <<< "$(cat)"; then
  bash "${CLAUDE_PLUGIN_ROOT}/scripts/play-sound.sh" auraa.mp3
fi

exit 0
