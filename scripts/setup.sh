#!/bin/bash
# setup.sh — (re-)download all meme sounds from myinstants into assets/.
# The repo already ships with committed .mp3 files; run this only if you
# want to refresh them, replace a single sound, or verify downloads work.
#
# Usage:
#   bash scripts/setup.sh            # download missing sounds only
#   bash scripts/setup.sh --force    # overwrite existing files
#   bash scripts/setup.sh <slug>     # download just one by slug (see list below)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS="$SCRIPT_DIR/../assets"
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36"

# Sound mapping: "target-filename.mp3|myinstants-page-slug"
SOUNDS=(
  "submit.mp3|vine-boom-sound-70972"
  "rizz.mp3|rizz-sound-effect-54189"
  "faaah.mp3|faaah-63455"
  "notification.mp3|among-us-role-reveal-sound-34956"
  "session-start.mp3|spiderman-meme-song-37638"
  "session-end.mp3|tuco-get-out-30566"
  "subagent-stop.mp3|dexter-meme-26140"
  "pre-compact.mp3|cat-laugh-meme-1-15761"
  "edit-write.mp3|anime-wow"
  "auraa.mp3|auraa-81623"
)

FORCE=0
ONLY=""
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    *) ONLY="$arg" ;;
  esac
done

download_one() {
  local target="$1"
  local slug="$2"
  local out="$ASSETS/$target"

  if [ -f "$out" ] && [ "$FORCE" -eq 0 ]; then
    echo "SKIP (exists): $target"
    return
  fi

  local page_url="https://www.myinstants.com/en/instant/$slug/"
  local mp3_path
  mp3_path=$(curl -sL -A "$UA" "$page_url" | grep -oE "/media/sounds/[^\"']*\.mp3" | head -1)

  if [ -z "$mp3_path" ]; then
    echo "FAIL (no mp3 url found): $target <- $page_url"
    return 1
  fi

  local mp3_url="https://www.myinstants.com$mp3_path"
  if curl -sfL -A "$UA" -o "$out" "$mp3_url"; then
    echo "OK:   $target <- $mp3_url"
  else
    echo "FAIL (download): $target <- $mp3_url"
    return 1
  fi
}

mkdir -p "$ASSETS"

for entry in "${SOUNDS[@]}"; do
  target="${entry%%|*}"
  slug="${entry##*|}"

  if [ -n "$ONLY" ] && [ "$ONLY" != "$slug" ] && [ "$ONLY" != "$target" ]; then
    continue
  fi

  download_one "$target" "$slug" || true
done

echo ""
echo "Done. Sounds in: $ASSETS"
