#!/bin/bash
# play-sound.sh <default_sound> [<event_name>]
#
# Plays a sound from the plugin's assets/ directory.
# Cross-platform: macOS (afplay), Linux (paplay/aplay), Windows (PowerShell).
#
# If $2 (event_name) is supplied, the script consults config.json via
# notify-config.sh to honor user-configured enable/disable + sound override.
# If $2 is omitted, legacy behavior: just play $1 unconditionally.

DEFAULT_SOUND="$1"
EVENT_NAME="$2"

if [ -n "$EVENT_NAME" ]; then
  # shellcheck disable=SC1091
  . "${CLAUDE_PLUGIN_ROOT}/scripts/notify-config.sh"
  notify_consult "$EVENT_NAME" "$DEFAULT_SOUND"
  if [ "$NOTIFY_PLAY" = "0" ]; then
    exit 0
  fi
  SOUND_FILE="${CLAUDE_PLUGIN_ROOT}/assets/$NOTIFY_SOUND"
else
  SOUND_FILE="${CLAUDE_PLUGIN_ROOT}/assets/$DEFAULT_SOUND"
fi

if [ ! -f "$SOUND_FILE" ]; then
  exit 0
fi

case "$(uname -s)" in
  Darwin*)
    afplay "$SOUND_FILE" &>/dev/null &
    ;;
  Linux*)
    if command -v paplay &>/dev/null; then
      paplay "$SOUND_FILE" &>/dev/null &
    elif command -v aplay &>/dev/null; then
      aplay -q "$SOUND_FILE" &>/dev/null &
    fi
    ;;
  MINGW*|MSYS*|CYGWIN*)
    # Git Bash / MSYS2 / Cygwin on Windows
    PS_SCRIPT="${CLAUDE_PLUGIN_ROOT}/scripts/play-sound.ps1"
    if command -v cygpath &>/dev/null; then
      WIN_SOUND=$(cygpath -w "$SOUND_FILE")
      WIN_PS=$(cygpath -w "$PS_SCRIPT")
    else
      WIN_SOUND="$SOUND_FILE"
      WIN_PS="$PS_SCRIPT"
    fi
    powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "$WIN_PS" "$WIN_SOUND" &>/dev/null &
    ;;
esac

# Detach so Claude Code doesn't wait on audio playback
disown 2>/dev/null
exit 0
