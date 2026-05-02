#!/bin/bash
# Dispatcher for the Notification hook: picks a sound based on the message.
# Claude Code sends JSON on stdin with a `message` field; when usage limits
# are hit the message contains "limit", so we play limit.mp3 for that case
# and fall back to notification.mp3 for everything else.

INPUT=$(cat)

if echo "$INPUT" | grep -qi 'limit'; then
  SOUND="limit.mp3"
else
  SOUND="notification.mp3"
fi

exec bash "${CLAUDE_PLUGIN_ROOT}/scripts/play-sound.sh" "$SOUND"
