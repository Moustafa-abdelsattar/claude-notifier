#!/bin/bash
# play-sound.sh <filename>
# Plays a sound from the plugin's assets/ directory.
# Cross-platform: macOS (afplay), Linux (paplay/aplay), Windows (PowerShell).

SOUND_FILE="${CLAUDE_PLUGIN_ROOT}/assets/$1"

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
