#!/bin/bash
# Dispatcher for the Notification hook: picks a sound based on the message.
# Claude Code sends JSON on stdin with a `message` field; when usage limits
# are hit the message contains "limit", so we play limit.mp3 for that case
# and fall back to notification.mp3 for everything else.
#
# Honors config.json overrides via play-sound.sh — the limit branch is treated
# as a distinct event "NotificationLimit" so it can be toggled or sound-swapped
# independently from the regular Notification event.

INPUT=$(cat)

if echo "$INPUT" | grep -qi 'limit'; then
  exec bash "${CLAUDE_PLUGIN_ROOT}/scripts/play-sound.sh" limit.mp3 NotificationLimit
else
  exec bash "${CLAUDE_PLUGIN_ROOT}/scripts/play-sound.sh" notification.mp3 Notification
fi
