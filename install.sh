#!/usr/bin/env bash
set -euo pipefail

SKILL_NAME="${SKILL_NAME:-zero-engineering-standard}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
NO_BACKUP="${NO_BACKUP:-0}"

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$CODEX_HOME/skills/$SKILL_NAME"
SKILLS_DIR="$CODEX_HOME/skills"

log() {
  printf '[zero-engineering-standard] %s\n' "$1"
}

if [ ! -f "$SOURCE_DIR/SKILL.md" ]; then
  printf 'SKILL.md not found. Please run this script from the skill repository root.\n' >&2
  exit 1
fi

if [ ! -d "$SOURCE_DIR/references" ]; then
  printf 'references directory not found. Please check the skill package is complete.\n' >&2
  exit 1
fi

log "Source: $SOURCE_DIR"
log "Target: $TARGET_DIR"

mkdir -p "$SKILLS_DIR"

if [ -e "$TARGET_DIR" ]; then
  if [ "$NO_BACKUP" = "1" ]; then
    log "Existing skill found. Removing without backup."
    rm -rf "$TARGET_DIR"
  else
    BACKUP_DIR="$TARGET_DIR.backup.$(date +%Y%m%d%H%M%S)"
    log "Existing skill found. Moving it to: $BACKUP_DIR"
    mv "$TARGET_DIR" "$BACKUP_DIR"
  fi
fi

log "Copying skill files..."
mkdir -p "$TARGET_DIR"

if command -v rsync >/dev/null 2>&1; then
  rsync -a --exclude '.git' "$SOURCE_DIR/" "$TARGET_DIR/"
else
  cp -R "$SOURCE_DIR/." "$TARGET_DIR/"
  rm -rf "$TARGET_DIR/.git"
fi

if [ ! -f "$TARGET_DIR/SKILL.md" ]; then
  printf 'Install failed: SKILL.md was not copied.\n' >&2
  exit 1
fi

if [ ! -d "$TARGET_DIR/references" ]; then
  printf 'Install failed: references directory was not copied.\n' >&2
  exit 1
fi

log "Installed successfully."
log "Restart Codex or open a new Codex thread to ensure the skill is discovered."
