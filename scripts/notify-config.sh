#!/bin/bash
# notify-config.sh — runtime configuration consultation for claude-notifier.
#
# Source this from a player script, then call:
#     notify_consult <event_name> <default_sound>
#
# After it returns, the calling script reads:
#     $NOTIFY_PLAY  → 1 (play) or 0 (skip)
#     $NOTIFY_SOUND → resolved sound filename
#
# Resolution order:
#   1. config.json missing or unreadable → legacy behavior (always play default)
#   2. node missing                      → legacy behavior
#   3. config.json `enabled: false`      → skip
#   4. config.json `events.<event>.enabled: false` → skip
#   5. config.json `events.<event>.sound: "<file>"` → override default
#   6. otherwise → play default
#
# Config schema (config.json):
#   {
#     "enabled": true,
#     "events": {
#       "UserPromptSubmit": { "enabled": true, "sound": "submit.mp3" },
#       "Stop":             { "enabled": true, "sound": "rizz.mp3"   },
#       ...
#     }
#   }
#
# Config file is gitignored — user-managed, written by the Meso /notifier UI.

notify_consult() {
  local event="$1"
  local default_sound="$2"

  NOTIFY_PLAY=1
  NOTIFY_SOUND="$default_sound"

  local cfg="${CLAUDE_PLUGIN_ROOT}/config.json"
  [ -f "$cfg" ] || return 0
  command -v node >/dev/null 2>&1 || return 0

  local out
  out=$(
    CLAUDE_NOTIFIER_CFG="$cfg" \
    CLAUDE_NOTIFIER_EVENT="$event" \
    CLAUDE_NOTIFIER_DEFAULT="$default_sound" \
    node -e '
      (function () {
        const fs = require("fs");
        try {
          const c = JSON.parse(fs.readFileSync(process.env.CLAUDE_NOTIFIER_CFG, "utf8"));
          if (c.enabled === false) { console.log("SKIP"); return; }
          const e = (c.events || {})[process.env.CLAUDE_NOTIFIER_EVENT] || {};
          if (e.enabled === false) { console.log("SKIP"); return; }
          const sound = (typeof e.sound === "string" && e.sound.length > 0)
            ? e.sound
            : process.env.CLAUDE_NOTIFIER_DEFAULT;
          console.log("PLAY " + sound);
        } catch (err) {
          console.log("PLAY " + process.env.CLAUDE_NOTIFIER_DEFAULT);
        }
      })();
    ' 2>/dev/null
  )

  case "$out" in
    SKIP)
      NOTIFY_PLAY=0
      ;;
    "PLAY "*)
      NOTIFY_SOUND="${out#PLAY }"
      ;;
    *)
      ;;  # leave defaults
  esac
}
